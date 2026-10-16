class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.1/kilo-proxy-headless-0.67.1-darwin-amd64.tar.gz"
      sha256 "531e74c822700a7abe6c3fa7315391308037eeeeee9bf560686068ccab37354b"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.1/kilo-proxy-headless-0.67.1-darwin-arm64.tar.gz"
      sha256 "7a41a0f35f673b62786958d695e821a9cea377a7ad91cfcbd904fcefe9b8d518"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.1/kilo-proxy-headless-0.67.1-linux-amd64.tar.gz"
      sha256 "af868f3bfe2ebe0a76034c7fe757dccd3b6eeaf06bedfa05c0d8927ccdd601f7"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.67.1/kilo-proxy-headless-0.67.1-linux-arm64.tar.gz"
      sha256 "84231d62661e3fd4756c0cfb2d64a0e7f7ab8175586ee0cc44652b71ef0e3279"
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
