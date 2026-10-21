cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.5"
  sha256 arm:   "6b00cd605718d57130b1044cd5e47ffa790a248d25b5d3f77f41c93be1cf48bd",
         intel: "3d86f990464cd8f97e7e307c7c018ba5c7fb25f3ddc622a4c51be9d71fd59ad1"

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
