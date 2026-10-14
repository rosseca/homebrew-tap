class KiloProxyHeadless < Formula
  desc "Console-only local proxy for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.64.0/kilo-proxy-headless-0.64.0-darwin-amd64.tar.gz"
      sha256 "eae15a638154fabc38c16417ad5c62d9fc7bd620e1b8d56d7de5be9508dcc54c"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.64.0/kilo-proxy-headless-0.64.0-darwin-arm64.tar.gz"
      sha256 "e0a1238f2e23334f063db6e4b0d1a1b2fdccaae0f0843a135e612d69c8d19156"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.64.0/kilo-proxy-headless-0.64.0-linux-amd64.tar.gz"
      sha256 "59ce24c2684feb69b42537825ec523aeb98672e9c196eef6118e96ba628f2d6a"
    end
    on_arm do
      url "https://github.com/rosseca/kilo-proxy/releases/download/v0.64.0/kilo-proxy-headless-0.64.0-linux-arm64.tar.gz"
      sha256 "48870a2216dd6e3fe880bbc96ec98a5a785ce1d5d8ff3657643483de9dc9bbaa"
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
