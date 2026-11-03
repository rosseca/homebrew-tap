cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.1"
  sha256 arm:   "7222d889add14643731668e9c5c32c2410bf4d124a72ad31f875e1d9a8b43479",
         intel: "74286de9def520615c421db7d9699dec1c232b3c5bd75e205779b77b9549eb7a"

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
