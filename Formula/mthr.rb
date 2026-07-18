class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.28"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.28/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "5f74b5da01ca3663ccb8aa45642bbc4fbb04eb304cca7ea762fa3a8c1c6e8591"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.28/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "085865ad63f4654824ba6235b615cf4dd28284917ee8f0cdaa4534cc2a6e32ec"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.28/mthr-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "e98fbbff93a1a7b70a06b1011affe160e5937863179bc9c5a3ad0990639aee0a"
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
