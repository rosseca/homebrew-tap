class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.8/kilo-proxy-headless-0.68.8-darwin-amd64.tar.gz"
      sha256 "9b489d891d99dd4e0322af511ed5275b860eb3f0da5e51ad17ad1690a118ff3d"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.8/kilo-proxy-headless-0.68.8-darwin-arm64.tar.gz"
      sha256 "7b08c5546203449602870e5dc8705413bb4e96df23aa3d5ad0a29374781016ac"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.8/kilo-proxy-headless-0.68.8-linux-amd64.tar.gz"
      sha256 "d5a5790bd4cf8041b170952bd649f8f54ff107dc2b435f697c8940b53bef620f"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.8/kilo-proxy-headless-0.68.8-linux-arm64.tar.gz"
      sha256 "199c81a51ff7f2a618c383f1e3e3475c64efa00ef1b6fcb1a6ef42b168802caf"
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
