cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.62.2"
  sha256 arm:   "6c4df312d4d4aad90d9b56086dfcac8c0dab8820ed61eb4598b1fec7c933bc6b",
         intel: "3b4d7ed4adb3d306590010886575d55d252f9b534c52cb7a6b3c461921e3c02c"

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
