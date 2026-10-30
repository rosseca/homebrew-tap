class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.0/kilo-proxy-headless-0.68.0-darwin-amd64.tar.gz"
      sha256 "3b3ba7ac1100c165076d59d1a6769b42497d657b8ac2c3ea2e91d3525f63d76c"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.0/kilo-proxy-headless-0.68.0-darwin-arm64.tar.gz"
      sha256 "5c316b0aab973e98df289bd849f72d57bbed95df152aa1ecf7b5d7713d9f1e42"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.0/kilo-proxy-headless-0.68.0-linux-amd64.tar.gz"
      sha256 "536c25a9e48aa0457353113cc525d9f6a81d5a531eb6c0223db909427bc57304"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.0/kilo-proxy-headless-0.68.0-linux-arm64.tar.gz"
      sha256 "bc112a8c7a2df5f2db2cb668a26982fac28b7db4b0e06a72a26b1450f894a92f"
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
