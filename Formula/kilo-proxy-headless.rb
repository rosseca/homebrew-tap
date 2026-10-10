class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"
  version "0.56.3"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.56.3/kilo-proxy-headless-0.56.3-darwin-amd64.tar.gz"
      sha256 "ca8124a8cd1cab3815ab4037979a09ef0f3388fbac8e32f36397921a1c9c2f2d"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.56.3/kilo-proxy-headless-0.56.3-darwin-arm64.tar.gz"
      sha256 "f60f0db82f12d0b1576fa96de605b30aac7fcfe52a1d35f87e44b5df976dc8b1"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.56.3/kilo-proxy-headless-0.56.3-linux-amd64.tar.gz"
      sha256 "1b8403c1598b7af99a6023be869bde6a05e0250f5546705c2c6d05f7e171fdab"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.56.3/kilo-proxy-headless-0.56.3-linux-arm64.tar.gz"
      sha256 "5b40407a202f177efee04cf9a0bb733b1b432b04c5cb637f636784519b488d66"
    end
  end

  def install
    bin.install "kilo-proxy-headless"
    pkgshare.install "README.md", "THIRD-PARTY-NOTICES.txt", "docs", "third_party"
  end

  def caveats
    <<~EOS
      Setup is explicit: run kilo-proxy-headless help to get started.
      The headless profile is separate from the desktop app by default.

      Kilo Proxy's own service and terminal wrappers record the current binary
      path. Before upgrading, stop and uninstall an installed Kilo Proxy service.
      After upgrading, reinstall your terminal commands and service with the
      same --config-dir, then start the service. Profiles are preserved.
      This formula does not install a service or terminal wrappers automatically.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/kilo-proxy-headless --version").strip
    library = {
      schemaVersion: 1,
      defaultModel:  "vendor/test",
      models:        [{
        id:              "vendor/test",
        contextPreset:   "custom",
        contextWindow:   32_768,
        reasoningCustom: true,
        reasoningLevels: ["high"],
        reasoningEffort: "high",
      }],
    }
    (testpath/"models.json").write JSON.generate(library)
    system bin/"kilo-proxy-headless", "--config-dir", testpath/"profile",
           "models", "import", testpath/"models.json"
    exported = JSON.parse(shell_output("#{bin}/kilo-proxy-headless --config-dir #{testpath}/profile models export -"))
    assert_equal "vendor/test", exported.fetch("defaultModel")
    model = exported.fetch("models").fetch(0)
    assert_equal "vendor/test", model.fetch("id")
    assert_equal 32_768, model.fetch("contextWindow")
    assert_equal "high", model.fetch("reasoningEffort")
  end
end
