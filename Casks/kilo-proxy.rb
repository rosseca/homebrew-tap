cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.56.3"
  sha256 arm:   "b21771c94a404461e2fcebf0579165e224abe75c2ba3cd63e78b29da1b535568",
         intel: "271a9a08d6457802e6625431c88865e8bd97cdb8d1289f582088e7a9e2a0e01a"

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
