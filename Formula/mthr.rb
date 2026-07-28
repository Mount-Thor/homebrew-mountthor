class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.35"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.35/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "14f497138f6dd274049bc4b1a992a21f82fb0cd1aa5de7fd502e5c71ccf15bac"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.35/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "765596f56ec90b445f845583e768a49a22a04e8db9c8b34e472481cc0b836526"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mthr/v0.3.35/mthr-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "73d6818612a157c87caa9d0e1220cc26cef9cfda71aaf36775c2df8dc0642464"
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
