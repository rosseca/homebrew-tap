cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.1"
  sha256 arm:   "b8b3d350fd3d7bfea3189d450296c754274a8cd2867dababc3eeeaaaf3edff21",
         intel: "1e4ae8bfdce508e48168be4cde15e9987ea89593a1af3d34898fb665f373845d"

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
