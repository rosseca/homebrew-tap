class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.8/kilo-proxy-headless-0.67.8-darwin-amd64.tar.gz"
      sha256 "56c55c6583494871f5dcc21642807b412f5cfb405602959329d67900ee59115f"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.8/kilo-proxy-headless-0.67.8-darwin-arm64.tar.gz"
      sha256 "71c9a87a1164bce89082f375d60faa81a748576a8ca4727df782f49738837cbe"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.8/kilo-proxy-headless-0.67.8-linux-amd64.tar.gz"
      sha256 "773358a4f08c6f01cade7dd7826b9b4b46455dd9eb60f482df68245312ccbe6e"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.8/kilo-proxy-headless-0.67.8-linux-arm64.tar.gz"
      sha256 "4f115c324530c84c40431ee3248ed1f636e209d8e36735b85580b199bfae611e"
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
