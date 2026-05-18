class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.1.10"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.10/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "3ce2bb0a7e09750a67e7ed03826afc088890fff4dbc104f031bee1399fd8f2f3"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.10/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "5fb201bed2277c4599bd7032c8b7a522e35e01ea7ec52c46775f52be4af6ac97"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.10/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "83510c8377dc135ce8753ce38d47c3fbae845042b82777c5c9c3d1ab3095d977"
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
