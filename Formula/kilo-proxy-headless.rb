class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.1/kilo-proxy-headless-0.68.1-darwin-amd64.tar.gz"
      sha256 "9246aabdb7abf554e5ae30bbe5c4c332ada6d26177aa33f680e8797cbc700ff1"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.1/kilo-proxy-headless-0.68.1-darwin-arm64.tar.gz"
      sha256 "4d298aa9c38b17f6c6475ec0fc9b63be3ca0c2c5ebd770c1221ba96eaf4934d1"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.1/kilo-proxy-headless-0.68.1-linux-amd64.tar.gz"
      sha256 "08361e64595b7819ad75ae1d2115bdc163c81e355bcdbc060449f3ed9803c705"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.1/kilo-proxy-headless-0.68.1-linux-arm64.tar.gz"
      sha256 "36cd229c4d59a35af99ae65702dbd0546a7fc5316ed43a60cb1a3819508c7485"
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
