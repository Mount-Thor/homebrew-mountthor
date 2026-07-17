class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.27"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.27/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "6c6bc25b475890a14a8ea8eb9c084ab93fb515b9eaedfc1d07904a8d472268cc"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.27/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "7964c934c238625974047d3f227e69f1cd8a966ef3ba43e6c2482c8322ded310"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.27/mthr-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "5e4c5d4a3bd70a1da5201346427a00ca6fa190f0cb66065086d527c0faedbd78"
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
