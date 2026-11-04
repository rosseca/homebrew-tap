class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.2/kilo-proxy-headless-0.68.2-darwin-amd64.tar.gz"
      sha256 "11292df0f93a73aaff9f2d8de4bcac3b6f737c7710ee8e25c03158ddbbc8e9e7"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.2/kilo-proxy-headless-0.68.2-darwin-arm64.tar.gz"
      sha256 "d49857964c08aa4429a77886d7dd89ae162030d4db98c65666171ab453b189d4"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.2/kilo-proxy-headless-0.68.2-linux-amd64.tar.gz"
      sha256 "ae7d30bab43632f70dc552318e81c717b4bc3ee612d9edf97c7894f3fe79bbb3"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.2/kilo-proxy-headless-0.68.2-linux-arm64.tar.gz"
      sha256 "6003ebcb35787b59b9ad6bffc6d95a9f23acfdd6d9d0ad712c110c248ba6d731"
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
