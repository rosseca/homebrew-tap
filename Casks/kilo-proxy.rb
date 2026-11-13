cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.6"
  sha256 arm:   "574d0d9be04afc4cf5915819b644b72159bb042d3beb9a27f7d97a6f9df555e4",
         intel: "66802d96b3943ea1746915cc8011396776d9f54b34c72e1cc6f45431f12697d0"

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
