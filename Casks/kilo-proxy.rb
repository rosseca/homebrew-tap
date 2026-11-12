cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.5"
  sha256 arm:   "29073723b64e779dd1725bb964120e15299701f36d397a6b040f45f9564fd76f",
         intel: "f0862a2eac4f40ac88b95d9e4733d3bca3c475b2d5c5f1dddb94075192b9c7c0"

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
