class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.0/kilo-proxy-headless-0.67.0-darwin-amd64.tar.gz"
      sha256 "8da23c7efcb8e6721e76f8867fb21cb6475aca918b817bee9e3acec051082e9c"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.0/kilo-proxy-headless-0.67.0-darwin-arm64.tar.gz"
      sha256 "aead1d320e85ad5edad5265cc5ca6fecce4ad24eedb7ac83ac05cc8e316b25a8"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.0/kilo-proxy-headless-0.67.0-linux-amd64.tar.gz"
      sha256 "39d41400423ff2a5bcf2a23d277cdc1b3b2fd71ec95eb79f7d4eeddd475d84a9"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.0/kilo-proxy-headless-0.67.0-linux-arm64.tar.gz"
      sha256 "bc1da119b3e64dc4c211baa6c4d8b31be9af964ba951f629de56a534ff2b0279"
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
