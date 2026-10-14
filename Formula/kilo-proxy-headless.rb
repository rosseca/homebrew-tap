class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.65.1/kilo-proxy-headless-0.65.1-darwin-amd64.tar.gz"
      sha256 "48c76cba142be1b2f5c3d097fa8d4594008ad8761fa21c7ab372e04f4b24f3ef"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.65.1/kilo-proxy-headless-0.65.1-darwin-arm64.tar.gz"
      sha256 "579253dd7aa7871c9efabd83603c1be1710d267f84944dd829f055134dc4a7ad"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.65.1/kilo-proxy-headless-0.65.1-linux-amd64.tar.gz"
      sha256 "81b57005539fa9e64b90220b7bbd7fde9b544c2d0de17fb8c2bc3806b0e20a34"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.65.1/kilo-proxy-headless-0.65.1-linux-arm64.tar.gz"
      sha256 "b090bd7979d97677994ce1e44c6c865939d7a21fdd1cc92acd6234be4742d7f7"
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
