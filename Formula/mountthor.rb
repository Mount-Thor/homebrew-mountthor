class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.9"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mountthor/v0.3.9/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "36c0955d04d8ce6222439bfade0dc8f0812b40cafc2a37236d81d7cd10203689"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.3.9/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "b4f8ab755e517c98c00b4eeb46b2aa110cc3807b8b6db0569fe78a7c5a7ce93d"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mountthor/v0.3.9/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "7097dcc37a7c695424ab74746f2e21c86799f18137ec3f95378260ef8780d466"
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
