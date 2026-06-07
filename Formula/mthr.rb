class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.18"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.18/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "b551bdc4f25c276696db6b40d4d4094a0a39fa2db3aab61488ea730065ee3871"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.18/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "ab0c6f8280b5d9ca18d131f8e7578917946870fe2a19ad6f58e82ea1d654afc6"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.18/mthr-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "0e0b7e7e08748cfeeeb364c71c599e6525254527ccf259ff54539dc36be8bcc1"
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
