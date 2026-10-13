class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.63.3/kilo-proxy-headless-0.63.3-darwin-amd64.tar.gz"
      sha256 "e3948b6a9667c093249a928b3c15edae2647d9b09cc6ae24d94627a6ddb74b99"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.63.3/kilo-proxy-headless-0.63.3-darwin-arm64.tar.gz"
      sha256 "0bc1ea569df473b0240f61e1b41c8e2bf349f13ade34d3a28ab9ef049c264e1e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.63.3/kilo-proxy-headless-0.63.3-linux-amd64.tar.gz"
      sha256 "12dc09d6d0c67ab99f6bbb059cc3c8d4d0037218d4f2e771c0093eec3b330da7"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.63.3/kilo-proxy-headless-0.63.3-linux-arm64.tar.gz"
      sha256 "97f78991f6350a6b5156109a5a10940d510a427e34b7cfa0f55229c2fdef0fb7"
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
