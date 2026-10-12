class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.61.1/kilo-proxy-headless-0.61.1-darwin-amd64.tar.gz"
      sha256 "291f61078d9d7f57c2b2f902ea8e8eb4fe2e7af1647042ad76d43d3225e6c8bd"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.61.1/kilo-proxy-headless-0.61.1-darwin-arm64.tar.gz"
      sha256 "a94aba9fffe583964f4443fd011b7fcce23ce669214b66e1a161255deab300b1"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.61.1/kilo-proxy-headless-0.61.1-linux-amd64.tar.gz"
      sha256 "e8e0f176c0adb5099fe1a3965fc85d85e1f09ad1890341073fce84c737679798"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.61.1/kilo-proxy-headless-0.61.1-linux-arm64.tar.gz"
      sha256 "1ab2e320cc07009ba7080f1f5db4f4ca5d21d55b0eac3287b19d8f2c15437495"
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
