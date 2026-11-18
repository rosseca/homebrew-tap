class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.10/kilo-proxy-headless-0.68.10-darwin-amd64.tar.gz"
      sha256 "d92f7b4da56399938a131bb6094f04d53fbece727b8499470956b80859ce4779"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.10/kilo-proxy-headless-0.68.10-darwin-arm64.tar.gz"
      sha256 "bf41b9608b52238ef88b80e2d05c4ad54b249af8d64a251b199ad6bd53bdb973"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.10/kilo-proxy-headless-0.68.10-linux-amd64.tar.gz"
      sha256 "61477742b9c329cf9832a1a832ddaea269549427958c2530bebc3e77c26f7005"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.68.10/kilo-proxy-headless-0.68.10-linux-arm64.tar.gz"
      sha256 "af7980592e714d378f2a37c43dfe39a4eeb76609a3bfb3133e31bb7ddc2c6d37"
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
