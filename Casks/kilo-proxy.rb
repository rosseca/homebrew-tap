cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.6"
  sha256 arm:   "7a5fe1d80d588c701c1481135df283a984951fa379d6af8949fedd414091c5dd",
         intel: "dda16d12e14be074181e0c31e7c86fbc856da1a5f6bdd8c062f7a945226c861c"

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
