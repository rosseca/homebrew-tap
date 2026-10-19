cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.3"
  sha256 arm:   "cbe7baecc96bd892ff4485bbc66ed40ac46faaea3cd6695d09a751cebc8ca205",
         intel: "251e654ccf46be74b68007436bce3fc50f7579d88fefef4d42a7194f3b186c77"

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
