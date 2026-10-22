class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.6/kilo-proxy-headless-0.67.6-darwin-amd64.tar.gz"
      sha256 "e5a97f6530055cc44f444841f2f4fc9fe6e441da20c0e28711e90c7b3c32eca7"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.6/kilo-proxy-headless-0.67.6-darwin-arm64.tar.gz"
      sha256 "3509e3110f1aac0197de7ea261923d4ae3b74dd9c72e109cba181f534ae4a8e0"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.6/kilo-proxy-headless-0.67.6-linux-amd64.tar.gz"
      sha256 "9a44080e300de98e0ac02685a1cca784517bea2a8024d509039ce93661099a47"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.6/kilo-proxy-headless-0.67.6-linux-arm64.tar.gz"
      sha256 "6e1c834e8495b78a8f2fe423e09d99b1e8ce7b85d5b05a699838171ec7d43ea4"
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
