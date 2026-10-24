cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.7"
  sha256 arm:   "dcef5435b59e22520c941fa75e2e43acda47137f11b760345b11dd8de4fc6ee5",
         intel: "bdd8771f16d982daf2c467be7ee2a1104c1398c7750b15e2311c2e0f4d9d9cb0"

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
