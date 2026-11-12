class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.5/kilo-proxy-headless-0.68.5-darwin-amd64.tar.gz"
      sha256 "b8289e93d4c2968a2071983f089bf60e783a5590d693de953bba61e82ecb5076"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.5/kilo-proxy-headless-0.68.5-darwin-arm64.tar.gz"
      sha256 "35a03f1eb7930f1541930fff78a37d559315e7270345eff0f0a8e9be3cf44ceb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.5/kilo-proxy-headless-0.68.5-linux-amd64.tar.gz"
      sha256 "0af77af8604d1ee33b22e94a642096239ddf5e0a48252f6b002a4b09a4fe9dcc"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.5/kilo-proxy-headless-0.68.5-linux-arm64.tar.gz"
      sha256 "bc584c4e33fb1e8ace7f8aebd6449f44fdefaa19dc3d38f4e39a2f28e0164f9e"
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
