class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.29"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.29/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "58de7ccc26149171dd78b2649a460e13bb9c2e082ee89f848fc837edc10cb442"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.29/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "8ddcaf6afa204c0d63fb9181adda32d98b74b1a3e7e4422cc233b29579503766"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.29/mthr-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "ce3512c966b8136c89ac942f02e8b2e6e5184b65899ea0bef2d32710b5c47987"
    end
  end
  license "Apache-2.0"

  BINARY_ALIASES = {
    "aarch64-apple-darwin": {},
    "x86_64-apple-darwin": {},
    "x86_64-unknown-linux-gnu": {}
  }

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
    if OS.mac? && Hardware::CPU.arm?
      bin.install "mthr"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "mthr"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "mthr"
    end

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
