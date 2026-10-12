cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.61.1"
  sha256 arm:   "8993b51df9f26b3d3443220770443661240853a5bf28a0758f711d1e99e34f91",
         intel: "cb150612928e27d8ad507e8f91656c9ec0641e77fcb6e1b4db8f5d80163950b2"

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
