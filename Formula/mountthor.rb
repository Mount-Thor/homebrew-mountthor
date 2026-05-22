class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.2.12"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mountthor/v0.2.12/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "15b2ae0b9c72944653846ec4bbbb00a876862206afd26be17caa6b0ff4972574"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.2.12/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "b721203f5a8a1dd2b92ab0148c70f3fbeb47185cff14dfdfb6906322b1afc04e"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mountthor/v0.2.12/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "24d483c1e7e33a54861fa501a96553060de651d3533b916171065051177babeb"
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
