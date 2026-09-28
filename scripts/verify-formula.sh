#!/usr/bin/env bash
# Verify a Homebrew formula against the bytes the CDN actually serves.
#
# Every `sha256` a formula pins is a promise about the file at the `url` that
# precedes it. Generating the formula correctly is not enough: the published
# objects can be replaced after the formula merges, and then `brew install`
# fails the checksum for everyone until the formula is regenerated. Nothing in
# the release path re-reads that promise, so this script does, and CI runs it.
#
# Requires: curl, and one of sha256sum / shasum / openssl.
# `--check-latest` additionally requires jq.
#
# Exit codes are distinct because the two faults are not equally urgent:
#   0  every pinned digest matches, and (with --check-latest) the tap is current
#   1  a pinned digest does not match the served bytes — installs are broken now
#   2  usage error, or a formula this script cannot parse
#   3  digests are fine, but the tap is behind the published release past grace

set -euo pipefail

MANIFEST_URL="${MANIFEST_URL:-https://get.mountthor.com/manifest.json}"

# How long the tap may legitimately lag a freshly published release before that
# lag is a fault. The mthr-cli release lane verifies the formula against the CDN
# and then merges its own pull request within the same run
# (`scripts/release/release_tap.sh`), waiting up to 15 minutes for GitHub to
# accept the merge. So a couple of hours covers a normal release comfortably,
# and a tap still behind after that means the lane's merge did not happen —
# which is the fault worth reporting, not a reviewer who has yet to look.
LAG_GRACE_HOURS="${LAG_GRACE_HOURS:-2}"

# Optional key=value sink so CI can act on *why* this failed without parsing
# the human-readable report above it.
STATUS_FILE="${VERIFY_STATUS_FILE:-}"

EXIT_OK=0
EXIT_DIGEST=1
EXIT_USAGE=2
EXIT_BEHIND=3

usage() {
  cat <<'USAGE'
Verify a Homebrew formula against the bytes the CDN actually serves.

Usage:
  scripts/verify-formula.sh [--check-latest] [FORMULA]

  FORMULA         Path to the formula (default: Formula/mthr.rb).
  --check-latest  Also require the formula's version to equal the `latest`
                  version in the release manifest, once that release is older
                  than LAG_GRACE_HOURS (default 2). Use this on a schedule,
                  not on a pull request: between cutting a release and merging
                  its formula pull request the tap is legitimately behind.

Environment:
  MANIFEST_URL         Release manifest (default https://get.mountthor.com/manifest.json)
  LAG_GRACE_HOURS      Grace before a lagging tap is a fault (default 2)
  VERIFY_STATUS_FILE   If set, key=value results are appended here for CI

Exit codes:
  0  digests match (and the tap is current)
  1  a pinned digest does not match the served bytes — installs are broken
  2  usage error, or an unparseable formula
  3  digests fine, but the tap is behind the published release past grace
USAGE
}

emit() {
  [ -n "${STATUS_FILE}" ] || return 0
  printf '%s\n' "$1" >>"${STATUS_FILE}"
}

# Pick a digest tool once, up front. macOS has shasum but not sha256sum, and a
# missing tool must not surface as a cryptic failure after the first download.
if command -v sha256sum >/dev/null 2>&1; then
  digest_of() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
  digest_of() { shasum -a 256 "$1" | cut -d' ' -f1; }
elif command -v openssl >/dev/null 2>&1; then
  digest_of() { openssl dgst -sha256 "$1" | awk '{print $NF}'; }
else
  echo "need one of sha256sum, shasum or openssl to hash downloads" >&2
  exit "${EXIT_USAGE}"
fi

# GNU and BSD date parse ISO-8601 with different flags; the script runs on both.
epoch_of() {
  date -u -d "$1" +%s 2>/dev/null ||
    date -u -j -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s 2>/dev/null ||
    return 1
}

check_latest=0
formula=""
while [ $# -gt 0 ]; do
  case "$1" in
    --check-latest) check_latest=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo "unknown option: $1" >&2
      exit "${EXIT_USAGE}"
      ;;
    *)
      if [ -n "${formula}" ]; then
        echo "expected at most one formula path" >&2
        exit "${EXIT_USAGE}"
      fi
      formula="$1"
      ;;
  esac
  shift
done
formula="${formula:-Formula/mthr.rb}"

if [ ! -f "${formula}" ]; then
  echo "no such formula: ${formula}" >&2
  exit "${EXIT_USAGE}"
fi

if [ "${check_latest}" -eq 1 ] && ! command -v jq >/dev/null 2>&1; then
  echo "--check-latest needs jq to read ${MANIFEST_URL}" >&2
  exit "${EXIT_USAGE}"
fi

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

# Pair each `url` with the `sha256` that follows it. The generated formula
# always writes them adjacently, one pair per platform branch; anything else is
# a formula we do not understand and must not silently skip over.
#
# Both patterns are anchored to the start of the whitespace-trimmed line, so a
# commented-out stanza or a `url "` inside a string literal is neither verified
# as a pinned artifact nor treated as an unpairable formula.
pairs="${workdir}/pairs"
: >"${pairs}"
pending_url=""
pending_line=0
line_number=0
while IFS= read -r line || [ -n "${line}" ]; do
  line_number=$((line_number + 1))
  trimmed="${line#"${line%%[![:space:]]*}"}"
  case "${trimmed}" in
    url\ \"*\"*)
      if [ -n "${pending_url}" ]; then
        echo "${formula}:${pending_line}: url has no sha256 before the next url" >&2
        exit "${EXIT_USAGE}"
      fi
      pending_url="${trimmed#url \"}"
      pending_url="${pending_url%%\"*}"
      pending_line="${line_number}"
      ;;
    sha256\ \"*\"*)
      digest="${trimmed#sha256 \"}"
      digest="${digest%%\"*}"
      if [ -z "${pending_url}" ]; then
        echo "${formula}:${line_number}: sha256 with no preceding url" >&2
        exit "${EXIT_USAGE}"
      fi
      printf '%s\t%s\t%s\n' "${pending_url}" "${digest}" "${pending_line}" >>"${pairs}"
      pending_url=""
      ;;
  esac
done <"${formula}"

if [ -n "${pending_url}" ]; then
  echo "${formula}:${pending_line}: url has no sha256" >&2
  exit "${EXIT_USAGE}"
fi

pair_count="$(wc -l <"${pairs}" | tr -d ' ')"
if [ "${pair_count}" -eq 0 ]; then
  echo "${formula}: no url/sha256 pairs found — refusing to report success" >&2
  exit "${EXIT_USAGE}"
fi

echo "Verifying ${pair_count} pinned artifact digest(s) in ${formula}"
echo

digest_failures=0
while IFS="$(printf '\t')" read -r url expected at_line; do
  body="${workdir}/body"
  if ! curl --fail --silent --show-error --location \
    --retry 2 --retry-delay 5 --retry-max-time 120 --retry-connrefused \
    --max-time 120 \
    --output "${body}" "${url}" 2>"${workdir}/curl.err"; then
    echo "FAIL  ${url}"
    echo "      ${formula}:${at_line}: download failed: $(tr -d '\n' <"${workdir}/curl.err")"
    digest_failures=$((digest_failures + 1))
    continue
  fi
  actual="$(digest_of "${body}")"
  if [ "${actual}" = "${expected}" ]; then
    echo "ok    ${url}"
    echo "      ${actual}"
  else
    echo "FAIL  ${url}"
    echo "      ${formula}:${at_line} pins ${expected}"
    echo "      the CDN serves      ${actual}"
    digest_failures=$((digest_failures + 1))
  fi
done <"${pairs}"

emit "digest_failures=${digest_failures}"

behind=0
usage_fault=0
if [ "${check_latest}" -eq 1 ]; then
  echo
  formula_version="$(
    sed -n 's/^[[:space:]]*version "\([^"]*\)".*/\1/p' "${formula}" | head -n 1
  )"
  emit "formula_version=${formula_version}"
  if [ -z "${formula_version}" ]; then
    echo "FAIL  ${formula}: no version stanza — refusing to report success"
    usage_fault=1
    emit "tap_behind=unparseable_version"
  elif ! curl --fail --silent --show-error --location --retry 3 --max-time 60 \
    --output "${workdir}/manifest.json" "${MANIFEST_URL}"; then
    echo "FAIL  could not read ${MANIFEST_URL}"
    behind=1
    emit "tap_behind=manifest_unreadable"
  else
    latest="$(jq -r '.latest // empty' "${workdir}/manifest.json")"
    generated_at="$(jq -r '.generated_at // empty' "${workdir}/manifest.json")"
    emit "latest=${latest}"
    if [ -z "${latest}" ]; then
      echo "FAIL  ${MANIFEST_URL} has no .latest"
      behind=1
      emit "tap_behind=manifest_unreadable"
    elif [ "${latest}" = "${formula_version}" ]; then
      echo "ok    tap serves ${formula_version}, the latest published version"
      emit "tap_behind=no"
    else
      # The tap is behind. Whether that is a fault depends on how long the
      # newer release has been published: the manifest is regenerated by the
      # release that publishes it, so `generated_at` is when the clock started.
      lag_hours=""
      if [ -n "${generated_at}" ] && published_at="$(epoch_of "${generated_at}")"; then
        now_epoch="$(date -u +%s)"
        lag_hours=$(( (now_epoch - published_at) / 3600 ))
      fi
      emit "lag_hours=${lag_hours}"
      if [ -z "${lag_hours}" ]; then
        echo "FAIL  tap serves ${formula_version}, but ${latest} is published"
        echo "      (could not read .generated_at, so no grace could be applied)"
        behind=1
        emit "tap_behind=beyond_grace"
      elif [ "${lag_hours}" -ge "${LAG_GRACE_HOURS}" ]; then
        echo "FAIL  tap serves ${formula_version}, but ${latest} has been published"
        echo "      for ${lag_hours}h (grace ${LAG_GRACE_HOURS}h) — the release lane"
        echo "      never opened its formula pull request, failed to merge it, or"
        echo "      it was closed unmerged."
        behind=1
        emit "tap_behind=beyond_grace"
      else
        echo "ok    tap serves ${formula_version}; ${latest} published ${lag_hours}h ago"
        echo "      is within the ${LAG_GRACE_HOURS}h merge grace — not a fault yet."
        emit "tap_behind=within_grace"
      fi
    fi
  fi
fi

echo
# A wrong digest means every install fails right now, so it outranks a lagging
# tap, which only means installs are older than they should be.
if [ "${digest_failures}" -ne 0 ]; then
  echo "${digest_failures} pinned digest(s) do not match: this tap does not install cleanly."
  exit "${EXIT_DIGEST}"
fi
if [ "${usage_fault}" -ne 0 ]; then
  echo "This formula cannot be fully verified."
  exit "${EXIT_USAGE}"
fi
if [ "${behind}" -ne 0 ]; then
  echo "Every pinned digest is correct; the latest-release check is what failed."
  exit "${EXIT_BEHIND}"
fi
echo "All checks passed."
exit "${EXIT_OK}"
