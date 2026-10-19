class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.3/kilo-proxy-headless-0.67.3-darwin-amd64.tar.gz"
      sha256 "1bb51ddc927e0a45f0f86076b2f433243a940c4be613e054cdc8480df2d7a156"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.3/kilo-proxy-headless-0.67.3-darwin-arm64.tar.gz"
      sha256 "333a78ab4fef0e428848ac71da76a6eb4dcc81d4f7e750a5ed9e73e0d2f019fa"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.3/kilo-proxy-headless-0.67.3-linux-amd64.tar.gz"
      sha256 "6e46f82fdc0db6741ca10db92b233d3896a0f1c975bfc40274f50f9d83a37aec"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.3/kilo-proxy-headless-0.67.3-linux-arm64.tar.gz"
      sha256 "5f0b797e3dd8f896fcea79961e35186caa54b3e6f87ff64f022312de3e699ee9"
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
