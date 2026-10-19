class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.2/kilo-proxy-headless-0.67.2-darwin-amd64.tar.gz"
      sha256 "838f8846d8c72ae71f391f9dd745d9e57cff4e0ba24722035aae8078e4b575c5"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.2/kilo-proxy-headless-0.67.2-darwin-arm64.tar.gz"
      sha256 "cb47c20e97a3af56b08cf2e14f321d7e1246a14a36bffc379979a58a7a72fc3e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.2/kilo-proxy-headless-0.67.2-linux-amd64.tar.gz"
      sha256 "02f50c906d6a0268a501cb2bad6b3087aac363ce4018ca823cd861d509cff26f"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.2/kilo-proxy-headless-0.67.2-linux-arm64.tar.gz"
      sha256 "84baa25fb1738682d6516c650737b57a6627e8a7ec25773de0e1070426897fdf"
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
