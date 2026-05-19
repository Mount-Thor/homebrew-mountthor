class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.1.19"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mountthor/v0.1.19/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "d298e972417b49693946318f22794265ee2f55c32c682be96e0896d0265e3bf0"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.1.19/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "f11da8880ecfcd30a5e8edf3221d3723dd9a41bd1d19641df75c7574aca9c4d1"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mountthor/v0.1.19/mountthor-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "f2f8ce0756af07297572733cfcd129e382b76ba017ce297ae99523dbb3e209ce"
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
