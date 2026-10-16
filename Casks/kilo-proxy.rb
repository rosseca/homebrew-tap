cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.0"
  sha256 arm:   "7f00c79f744c5be8a98601fc303d59c50ceee8ee08cb2b9e1d2c3263596b929d",
         intel: "8c5f7f9b032f35d34d21cf3cecc214e5c4cacf007ea3aaec2d8ad12e0fd5a76c"

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
