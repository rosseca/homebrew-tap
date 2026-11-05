cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.3"
  sha256 arm:   "9a38b29f6d47c2061886db8f3193ef458fbe2f8df8b2fd4a50cc1ac5825b665d",
         intel: "113332dfa50f3fe033ee3138a2185a72e740fc548d37865df57fa5c6c31a27e9"

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
