class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.66.0/kilo-proxy-headless-0.66.0-darwin-amd64.tar.gz"
      sha256 "fd504ca22fc1ad641c96d0940093744beea2c1fae683d683b62a4bb813ea5dda"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.66.0/kilo-proxy-headless-0.66.0-darwin-arm64.tar.gz"
      sha256 "fbb878e1c626e7987f6a5116c5ebcd735f2724fde3d96824047ed4d45ac81829"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.66.0/kilo-proxy-headless-0.66.0-linux-amd64.tar.gz"
      sha256 "548f58aeceb11a96b1c416b94595ad15e76227717f687d0b40f28917a6f127a8"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.66.0/kilo-proxy-headless-0.66.0-linux-arm64.tar.gz"
      sha256 "7f2671c156293674ff47ff25a7e782ece204e380a0f625451cfc652dd28dd3d5"
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
