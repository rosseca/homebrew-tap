cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.0"
  sha256 arm:   "16ea05acea46101e9c6afd1e69e788f3eb9197f0ccca3b0396c5cd59f9e84748",
         intel: "de02584feb6e4e9d629f700ecbaf8362323979001f31d219a83a856027f96109"

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
