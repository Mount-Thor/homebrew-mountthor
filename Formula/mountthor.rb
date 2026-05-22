class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.2.10"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mountthor/v0.2.10/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "dcd146d6e6c3d326fdc44f46308a410f15e03a9ea3cc48ae72c29eaa20a3d766"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.2.10/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "77a709d9a42597ef3f66507772f11832c51c9fe29b05fa49e4b5f89dca9d7eb8"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mountthor/v0.2.10/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "c43d586e2e264df7ba4eb2e7fddbae4bca4fba636abb8063be15e39ceb068e0f"
  end
  license "Apache-2.0"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":     {},
    "x86_64-apple-darwin":      {},
    "x86_64-pc-windows-gnu":    {},
    "x86_64-unknown-linux-gnu": {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  depends_on "teleport"

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "mountthor" if OS.mac? && Hardware::CPU.arm?
    bin.install "mountthor" if OS.mac? && Hardware::CPU.intel?
    bin.install "mountthor" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
