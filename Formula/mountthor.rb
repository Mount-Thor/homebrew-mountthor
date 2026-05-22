class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.2.11"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mountthor/v0.2.11/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "39f4debfffab8571d6ef59271a90f214b4a6090e129a7e48495b6ac1edff2b8a"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.2.11/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "1f0251f4813d8cbb6c3da870108d8f77ec273bb5f8c2e737c4f7aeab871a0ab4"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mountthor/v0.2.11/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "a1b56022fcb79a866333ae1221e47ff971aa7e6bf04065619a6b1ae755e21765"
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
