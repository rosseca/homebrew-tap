class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.7/kilo-proxy-headless-0.68.7-darwin-amd64.tar.gz"
      sha256 "1f8f0b8e5b9fbce57de1a30e240bed61193e3f7b9684dbd0302116d89ae68f44"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.7/kilo-proxy-headless-0.68.7-darwin-arm64.tar.gz"
      sha256 "3a8d04c4637c482f976b2ad228c12ba5bac204020efbaad62a5049716bfea362"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.7/kilo-proxy-headless-0.68.7-linux-amd64.tar.gz"
      sha256 "9a1ccdc29002c8da384a90396cd70866551776452a10f95ca7f54532b8d465c4"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.7/kilo-proxy-headless-0.68.7-linux-arm64.tar.gz"
      sha256 "337385ef0692a3bb80fbe99ef7b3e2d97aa3386f52c64c0041e4d03bbdfdffbf"
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
