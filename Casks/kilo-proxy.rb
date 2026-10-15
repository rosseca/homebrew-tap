cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.66.0"
  sha256 arm:   "4657d4fbec7a8a51550ae70e4f158c30018e590ef0c231a1ca4d4390ab60dffe",
         intel: "06af9d7b40d901db589ea95c9889f733233e9ab2975d26f9f42a8a62e38cdc8b"

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
