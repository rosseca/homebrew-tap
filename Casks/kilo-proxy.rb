cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.63.3"
  sha256 arm:   "0ce81de2b9a37e6069e76f1ba52300299742a78058d3de12764027e868309467",
         intel: "a564711c7b0c6f3ca50b6481e08d04b36bea2f9df9cdc67d05278020e6aff7db"

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
