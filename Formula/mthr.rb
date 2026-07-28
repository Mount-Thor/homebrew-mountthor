class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.39"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.39/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "efffd189ce20f32821641bf950b3d1a4658ee653183b8074fc21b29fcda73b58"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.39/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "922f7e644889e97282ba0343d4cd39b57aff91903ab7d9e42004126aa6f5374d"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mthr/v0.3.39/mthr-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "eff82a437a081249bfd4433eaec44ff2a6400911d81f8f48bf4c2702c551df54"
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
