class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.4/kilo-proxy-headless-0.68.4-darwin-amd64.tar.gz"
      sha256 "81f4e6e1babf6f1b479c5fb6a44437a014c8b7c3381c716223dd5e15aa440629"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.4/kilo-proxy-headless-0.68.4-darwin-arm64.tar.gz"
      sha256 "2bd15d1542df0dc8d09e8a8130265ea91f9e0bc0ddb01e9d4ec3eae86049e926"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.4/kilo-proxy-headless-0.68.4-linux-amd64.tar.gz"
      sha256 "a922793949825570a714db54b7523ff81a3178522fee66da9e9b9c4660a41e75"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.4/kilo-proxy-headless-0.68.4-linux-arm64.tar.gz"
      sha256 "1f5725172d51b784500a96f1d5e90eb2625eed93e96aa02783d6f17ea3197e97"
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
