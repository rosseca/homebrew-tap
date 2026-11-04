cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.2"
  sha256 arm:   "6d565c9a53b577f0fcd79ffa6c28c6e319c2a85c69fbe1bc6be3a51355db1d61",
         intel: "f9bd5787937b56453b0da90951edf72a695bfaecfd06402d7a36f106e12ebfee"

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
