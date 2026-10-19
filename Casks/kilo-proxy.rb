cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.2"
  sha256 arm:   "2a408cee42a61072cc3c0c18f15b66450dc2659ddd5a53a6bfdb132a1c6598c2",
         intel: "f3a59df950e02c6a71987e7d3220bd9f38d77ae43bd5d3cb7d1d14b1d0bc05fc"

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
