class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.57.0/kilo-proxy-headless-0.57.0-darwin-amd64.tar.gz"
      sha256 "5148356f56e079c4e07a166a977a5340677dcd2aa65c717069de964c118e5f8a"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.57.0/kilo-proxy-headless-0.57.0-darwin-arm64.tar.gz"
      sha256 "63d9e35c5f3e6006b32ae558c1974ba0df71e81a72fb90eaeb0a6754aaf9c1fd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.57.0/kilo-proxy-headless-0.57.0-linux-amd64.tar.gz"
      sha256 "8dd3369fd1a298cdd18fb54bca3eb3e245df68135cf92e837a9ab879ecaa980b"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.57.0/kilo-proxy-headless-0.57.0-linux-arm64.tar.gz"
      sha256 "a5e2e603d57d0f1ff663cecb269af4e8f31f5124fb9e42df74a9903034fe4d43"
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
