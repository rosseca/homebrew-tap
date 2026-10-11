class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.60.0/kilo-proxy-headless-0.60.0-darwin-amd64.tar.gz"
      sha256 "b6c827edfd3f882604a48773bc670b3d81bf399fc2432cc703eb2728afdc8a04"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.60.0/kilo-proxy-headless-0.60.0-darwin-arm64.tar.gz"
      sha256 "cdea559770d16985a37c6bb1c53e7788d1fc6b27e5e592d5dd5c7b07cd210039"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.60.0/kilo-proxy-headless-0.60.0-linux-amd64.tar.gz"
      sha256 "6b1944d6e7f78a5954613084cc7d1f9a52c03eb126435533689ac720ebe2412c"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.60.0/kilo-proxy-headless-0.60.0-linux-arm64.tar.gz"
      sha256 "cbdd74b4d16bfceba9f235880bb497bcfeb3af227b6f0ec3321054ff677bd01e"
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
