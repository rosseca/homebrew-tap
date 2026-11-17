cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.68.7"
  sha256 arm:   "b215fd124872a473a4d68789eb8e8c3b99f4b535c43457af5db6b8b3b4adeeed",
         intel: "fc8cbffa14ce63a461431b8fb9a0e17011d04d90e1887e661ab6fc3070f81294"

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
