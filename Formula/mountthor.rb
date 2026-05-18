class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.1.9"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.9/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "e362dde0997397ad69144ddc35517ab400838cfccba3e61f5d701d19b956e5e6"
    end
    if Hardware::CPU.intel?
      url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.9/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "1614011bd08e586d113668f6d278e94b33baa6e09bc2583dec27758253fb1f88"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/Mount-Thor/mount-thor/releases/download/mountthor-v0.1.9/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "6662a6f89db14f8de000acc438346903afe1da86bdccecc6d974044aeeb4709d"
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
