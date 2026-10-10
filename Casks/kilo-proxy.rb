cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.57.0"
  sha256 arm:   "f971b3db4068eba58988e267875f111a8eceb7dcbf58f6c112922f43c72fcbf7",
         intel: "b495bee5d307f7f4a0ee8f9092e0b04b10d0f8966cf115cc9b9311e036003015"

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
