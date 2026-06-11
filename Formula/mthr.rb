class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.22"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.22/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "6548f6ab34c31f00af96b21fb895acf5e8da3d8ec672862e5039a999aa29a2e7"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.22/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "4ba1269f9086ac644cce9a82e24b60d5f5f86a9d0bbf289aabb75c16a93ff8c5"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.22/mthr-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "f2a68b7650481202bb8d6f3e2ff284029a40673247029371fca5024c95f7d339"
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
