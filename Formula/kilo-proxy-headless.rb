class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.5/kilo-proxy-headless-0.67.5-darwin-amd64.tar.gz"
      sha256 "d25f3d4f95f6b4b68460393e0ad54cfdf89be44305508e9bfe7f7d7dcbea8e5c"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.5/kilo-proxy-headless-0.67.5-darwin-arm64.tar.gz"
      sha256 "2df349b84aeb6834003756a20cb7a67ca398c5a2b12ae132c5e5fbe03616bc2e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.5/kilo-proxy-headless-0.67.5-linux-amd64.tar.gz"
      sha256 "cdb53b2634f6ed36e11302783d1b96599ec8902b394349adc8d320695173a63e"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.5/kilo-proxy-headless-0.67.5-linux-arm64.tar.gz"
      sha256 "1578c24df3055331fd556479785963a72c578862061a3c681f2c2865ce8f5bd0"
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
