cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.64.0"
  sha256 arm:   "edb9fc0ca20376f76c8ae1989d134bcfabb635cb5eefc5eb96e482816d1c00cd",
         intel: "24dfc11f588d4ad4bdcda370717493b5b8e61a1c95ec9e98aff3c1b6a7b7a134"

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
