class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.62.2/kilo-proxy-headless-0.62.2-darwin-amd64.tar.gz"
      sha256 "37bf661a8196515ac7aff9e8b78505a529f85a5a77a105726ce553c0d853334d"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.62.2/kilo-proxy-headless-0.62.2-darwin-arm64.tar.gz"
      sha256 "9e352e56ac0f2f5be1c33013d498b419c4e8b85495610722981dfdb9df6042a2"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.62.2/kilo-proxy-headless-0.62.2-linux-amd64.tar.gz"
      sha256 "1bfe0108c67475329224f1835f36de12c6eb4aa3477972a100ad3cbc0b1481fb"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.62.2/kilo-proxy-headless-0.62.2-linux-arm64.tar.gz"
      sha256 "fdb9a849ab7334cb3f0890785be667daaa859036d38646980c4ea9eaed076d2f"
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
