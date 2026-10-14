cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.65.1"
  sha256 arm:   "87e63505f09a64aab066268d0d2825e6a1fc1c744aebef29fe66212ee8264484",
         intel: "74826677e8bf8bdf07e441c8722550f5eaaa6139f600a69069893560456e0719"

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
