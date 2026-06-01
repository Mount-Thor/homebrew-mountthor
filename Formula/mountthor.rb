class Mountthor < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal leases, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.10"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mountthor/v0.3.10/mountthor-aarch64-apple-darwin.tar.xz"
      sha256 "c6f58ce7f5ade139582be084e5722f17013bb70b53a5d34712d9455c42c7cf0f"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.3.10/mountthor-x86_64-apple-darwin.tar.xz"
      sha256 "278ea7dbc2cd123893b11332334ef29419596135c64837f0e55f8fb560f0ca51"
    end
  end
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mountthor/v0.3.10/mountthor-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "13ba6249b32b52d1bf750c2f829d58a15edb3f5716b56bff145127f6bf4f8846"
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
      bin.install "mountthor"
    end
    if OS.mac? && Hardware::CPU.intel?
      bin.install "mountthor"
    end
    if OS.linux? && Hardware::CPU.intel?
      bin.install "mountthor"
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
