class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.3/kilo-proxy-headless-0.68.3-darwin-amd64.tar.gz"
      sha256 "1f4550b0507be66f96dcc1184aa628c7f04e9193228dbd40dec39fd07eaa349b"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.3/kilo-proxy-headless-0.68.3-darwin-arm64.tar.gz"
      sha256 "9825bc3460255f79a080dba51c02997f2bf7d28afcda5c6e05ac31b91682c3c0"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.3/kilo-proxy-headless-0.68.3-linux-amd64.tar.gz"
      sha256 "4cea6b530b11161aa3eb2705f64df8be9a82e449686e44fd3a118fcab1a928dd"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.3/kilo-proxy-headless-0.68.3-linux-arm64.tar.gz"
      sha256 "e611f0359577a57ba8ac24ae730229baadfeb82275df71c516765580be2844be"
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
