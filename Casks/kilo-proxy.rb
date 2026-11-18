cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.10"
  sha256 arm:   "ad8ee22e6731559ace109e406888d7f6087db0025fb8acb857dc5d09020f55a3",
         intel: "e15d9f2e94c2041447639d040c3b91c9a39df5def11d257f823b83e6cdd114e1"

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
