cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.4"
  sha256 arm:   "cf5e8fc7a86280be97b632b7ee6cb3cb0e27a0277eb37a976f3ac7bd0214ad55",
         intel: "1a9997790a9fa1f8bf217fc8612ec4b293ef7aadbe960037ea508e2ff64d2721"

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
