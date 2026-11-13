class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.6/kilo-proxy-headless-0.68.6-darwin-amd64.tar.gz"
      sha256 "7a639174ce698e9111811e1ccf12f575e315f5ce694b6128adb1971dbd3e1e67"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.6/kilo-proxy-headless-0.68.6-darwin-arm64.tar.gz"
      sha256 "07cbff32a9216b383cd0bd1aecb22f402a9fd49159366997b893ca6f628d1fc7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.6/kilo-proxy-headless-0.68.6-linux-amd64.tar.gz"
      sha256 "265d176e86b70532b02cc2b30e848a7fd1bfc44f0d98700a6acfe99aaebd43b5"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.6/kilo-proxy-headless-0.68.6-linux-arm64.tar.gz"
      sha256 "e5f915d6c10f279ece8a024979a050bcfc90f5036203a839fd2fc4aac6e4e34a"
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
