class Mthr < Formula
  desc "Mount Thor customer CLI for registration, API keys, sessions, bare-metal machines, and VM workflows"
  homepage "https://mountthor.com"
  version "0.3.48"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://get.mountthor.com/mthr/v0.3.48/mthr-aarch64-apple-darwin.tar.xz"
      sha256 "0a0b80b0a4782dcb54539ba5c0f06d5e4d1cfd61b7942039df10d61a02fcf7cb"
    end
    if Hardware::CPU.intel?
      url "https://get.mountthor.com/mthr/v0.3.48/mthr-x86_64-apple-darwin.tar.xz"
      sha256 "6289c2485863267fdab14ab5c02143d19879e6d3b52fd5c1387f6f1a0b68bd07"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://get.mountthor.com/mthr/v0.3.48/mthr-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "f364f4be15e3f84309e563745298acf92c05bb2475f0100756219121a5cdb255"
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

  def install_native_desktop_handler!
    # Mount Thor native bare-metal desktop URL handler.
    handler_source = buildpath/"mthr-desktop-handler.applescript"
    handler_source.write <<~APPLESCRIPT
      on open location the_url
        do shell script "nohup " & quoted form of "#{opt_bin}/mthr" & " desktop-handoff " & quoted form of the_url & " </dev/null >/dev/null 2>&1 &"
      end open location
    APPLESCRIPT

    handler_app = libexec/"Mount Thor Desktop.app"
    libexec.mkpath
    system "/usr/bin/osacompile", "-o", handler_app, handler_source
    handler_info = handler_app/"Contents/Info.plist"
    handler_info.unlink
    handler_info.write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleExecutable</key>
        <string>applet</string>
        <key>CFBundleIdentifier</key>
        <string>com.mountthor.desktop-handoff</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>Mount Thor Desktop</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleSignature</key>
        <string>aplt</string>
        <key>CFBundleURLTypes</key>
        <array>
          <dict>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>CFBundleURLName</key>
            <string>com.mountthor.desktop-handoff</string>
            <key>CFBundleURLSchemes</key>
            <array>
              <string>mthr</string>
            </array>
          </dict>
        </array>
        <key>LSMinimumSystemVersion</key>
        <string>13.0</string>
        <key>LSUIElement</key>
        <true/>
        <key>NSHighResolutionCapable</key>
        <true/>
      </dict>
      </plist>
    PLIST
    system "/usr/bin/codesign", "--force", "--deep", "--sign", "-", handler_app
  end

  def install
    bin.install "mthr" if OS.mac? && Hardware::CPU.arm?
    bin.install "mthr" if OS.mac? && Hardware::CPU.intel?
    bin.install "mthr" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!
    install_native_desktop_handler! if OS.mac?

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end

  def post_install
    return unless OS.mac?

    system "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
           "-f", opt_libexec/"Mount Thor Desktop.app"
  end
end
