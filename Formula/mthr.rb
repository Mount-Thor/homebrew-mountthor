class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.38"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.38/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "aaa5b1f53a7cf85da22a2c5385a9f27d7ab0e58393e15b49063525af6d824b5f"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.38/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "d2982cc9660af1ce30e29f334ab4ffd3537b43d63058aab4884313b56d4c1c2c"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mthr/v0.3.38/mthr-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "dd1dc37bb39e7f25b17da930dda12ace0cef93d30babd65ea2d8ed5851a4f394"
  end
  license "Apache-2.0"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":     {},
    "x86_64-apple-darwin":      {},
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
    bin.install "mthr" if OS.mac? && Hardware::CPU.arm?
    bin.install "mthr" if OS.mac? && Hardware::CPU.intel?
    bin.install "mthr" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
