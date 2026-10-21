class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.4/kilo-proxy-headless-0.67.4-darwin-amd64.tar.gz"
      sha256 "742c62b841bab8ecb10d0006a658bb5eddfb42160ff35b42058dcbee62655c44"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.4/kilo-proxy-headless-0.67.4-darwin-arm64.tar.gz"
      sha256 "41c2620a86ca32bca2284b9a8ce451a84ae3bb218a31fd0e4d3065faffa9de1e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.4/kilo-proxy-headless-0.67.4-linux-amd64.tar.gz"
      sha256 "0a15248ec5d3e4c1452ae9f0f9e3292ffbaa0bc3a9901983056a4a4b6aa30577"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.4/kilo-proxy-headless-0.67.4-linux-arm64.tar.gz"
      sha256 "5e0eec14273177c6b3c20d0118e8e1b4598cdf4eef6364267b0974a62dc8477c"
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
