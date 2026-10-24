class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.7/kilo-proxy-headless-0.67.7-darwin-amd64.tar.gz"
      sha256 "4c254cb1dcb19dd34e42e64d43a068cadcd66bc47f7c8a9776206873435c2f7b"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.7/kilo-proxy-headless-0.67.7-darwin-arm64.tar.gz"
      sha256 "5a3567d214d81ea5b686fa020043856f265bdfab1758cd653916268bdb9975ef"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.7/kilo-proxy-headless-0.67.7-linux-amd64.tar.gz"
      sha256 "0e010221acd36ab9e52ab7154e4f2d80cd97afd5bcd2640f97dd3bb2b6a02f89"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.7/kilo-proxy-headless-0.67.7-linux-arm64.tar.gz"
      sha256 "6859a5aa841859bea4c698a38792ec32cfff414477e39125bc183af689907768"
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
