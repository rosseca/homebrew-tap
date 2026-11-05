cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.4"
  sha256 arm:   "65382c6a67a7902e64c8ec848ed187fa782a4e4a6ffb1f405e0eec1f105be692",
         intel: "defa3891d4a385292bd3f11e044426bc5c81f269f3ff30f5f2387ece4a4f56a1"

  url "https://github.com/rosseca/kilo-proxy/releases/download/v#{version}/kilo-proxy-#{version}-darwin-#{arch}.zip"
  name "Kilo Proxy"
  desc "Local proxy and private workspaces for AI coding clients"
  homepage "https://github.com/rosseca/kilo-proxy"

  depends_on macos: :monterey

  app "kilo-proxy-#{version}-darwin-#{arch}/Kilo Proxy.app"

  caveats <<~EOS
    This cask preserves the upstream app's signing status and macOS quarantine.
    Homebrew does not sign or notarize the app or bypass Gatekeeper.
    Your Kilo Proxy profiles and chats are not removed by this cask.
  EOS
end
