cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.8"
  sha256 arm:   "98eee51c95da737fab9c6a2170e0b5c7c014e8588c5119a13ae1960d63972a91",
         intel: "a55b09062732819840ae700e7819549ad6d518ec9700fc07b418fc6386b3b9a4"

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
