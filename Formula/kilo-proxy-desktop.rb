class KiloProxyDesktop < Formula
  desc "Native desktop proxy for Kilo credits and supported agent clients"
  homepage "https://github.com/rosseca/kilo-proxy"
  url "https://github.com/rosseca/kilo-proxy.git",
      tag:      "v0.61.1",
      revision: "ad31f2fc90f21355e4f96957b443c2b4fb338bd4"

  depends_on "go" => :build
  depends_on "pkgconf" => :build
  depends_on "vulkan-headers" => :build
  depends_on "dbus" => :test
  depends_on "xorg-server" => :test

  depends_on "libx11"
  depends_on "libxcb"
  depends_on "libxcursor"
  depends_on "libxfixes"
  depends_on "libxkbcommon"
  depends_on :linux
  depends_on "mesa"
  depends_on "vulkan-loader"
  depends_on "wayland"

  def install
    odie "Source VERSION does not match the formula version" if (buildpath/"VERSION").read.strip != version.to_s

    ENV["CGO_ENABLED"] = "1"
    ENV["GOTOOLCHAIN"] = "local"

    # Gio resolves GLES and Vulkan with dlopen, so retain their search paths
    # even when the corresponding libraries are not linked directly.
    %w[mesa vulkan-loader].each do |dependency|
      ENV.append "CGO_LDFLAGS", "-Wl,-rpath,#{formula_opt_lib(dependency)}"
    end

    system "go", "build", *std_go_args(output: bin/"kilo-proxy", tags: "desktop",
                                     ldflags: "-X main.version=#{version}")

    (share/"icons/hicolor/scalable/apps").install "ui/icon.svg" => "kilo-proxy.svg"
    (share/"applications/kilo-proxy.desktop").write <<~DESKTOP
      [Desktop Entry]
      Type=Application
      Name=Kilo Proxy
      Comment=Connect your editors to your organization's Kilo credits
      Exec="#{opt_bin}/kilo-proxy"
      Icon=#{opt_share}/icons/hicolor/scalable/apps/kilo-proxy.svg
      Terminal=false
      Categories=Development;
    DESKTOP

    pkgshare.install "README.md", "THIRD-PARTY-NOTICES.txt", "docs"
    %w[gio fyne-systray systray].each do |dependency|
      source = buildpath/"third_party"/dependency
      next unless source.directory?

      notices = pkgshare/"third_party"/dependency
      notices.install source.glob("{LICENSE,PATCHES.md,*.patch}")
    end
  end

  def caveats
    <<~EOS
      Launch Kilo Proxy in a graphical Linux session:
        #{opt_bin}/kilo-proxy

      A session D-Bus and a working graphics driver are required. The tray
      requires StatusNotifierItem/AppIndicator support from your desktop.
      If your desktop does not search #{HOMEBREW_PREFIX}/share, the application
      menu entry will not appear automatically; the command above still works.

      Quit Kilo Proxy before upgrading. If you installed its optional terminal
      commands, install them again from Settings after upgrading so their
      executable paths refer to the new installation.

      For a server without a desktop, install kilo-proxy-headless instead.
      This formula does not configure credentials or install a user service.
    EOS
  end

  test do
    require "json"

    assert_equal version.to_s, shell_output("#{bin}/kilo-proxy --version").strip
    assert_path_exists share/"icons/hicolor/scalable/apps/kilo-proxy.svg"
    assert_match "#{opt_bin}/kilo-proxy", (share/"applications/kilo-proxy.desktop").read

    ENV["LIBGL_ALWAYS_SOFTWARE"] = "1"
    ENV["WAYLAND_DISPLAY"] = ""
    report = testpath/"desktop-report.json"
    # The diagnostic flag owns a temporary profile and a synthetic loopback
    # gateway; it does not read the user's credentials or contact inference.
    system "/bin/sh", "-c", 'exec "$@" >desktop-stdout.log 2>desktop-stderr.log',
           "kilo-desktop-test",
           formula_opt_bin("dbus")/"dbus-run-session", "--",
           formula_opt_bin("xorg-server")/"xvfb-run", "-a", "-s", "-screen 0 1280x1024x24",
           bin/"kilo-proxy", "--desktop-self-test", report
    data = JSON.parse(report.read)
    assert data.fetch("passed"), data["error"]
    assert_equal version.to_s, data.fetch("version")
    assert_equal "linux", data.fetch("os")
    assert_equal Hardware::CPU.arm64? ? "arm64" : "amd64", data.fetch("arch")
    %w[
      rendered-ui-and-authenticated-backend
      first-run-sign-in-guide
      window-and-tray-language-en
      window-and-tray-language-es
      native-clipboard-via-ui
      proxy-start-via-ui
      close-keeps-proxy
      tray-reopen-preserves-session
      tray-stop
      tray-appearance-persisted-icon
      tray-appearance-persisted-spend
      tray-appearance-persisted-icon-restored
      tray-appearance-persisted-balance
      shared-model-library-autosave
      primary-navigation-preserves-shared-models
      model-edit-survives-window-close
    ].each do |check|
      assert_includes data.fetch("checks"), check
    end
  end
end
