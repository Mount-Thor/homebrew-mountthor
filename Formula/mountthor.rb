class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.1.16"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.16/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "7e66ee62b963286659a98dd4030da76a032c5aa1415a0277fda14358a1bef29b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.16/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "7f1dcec04674fa36030ab9e0e28e5133937c79feb6ab19357e08f0a625ac59a3"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.16/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "1bdc6c64a28f509e78392b93cdfa8f1d6ad2a0b4d6227821ba90df2372b50ddb"
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
