cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.60.0"
  sha256 arm:   "3f8615156696f58352f57f515372f6f5a572da31b4abb31fda545828195efb9e",
         intel: "956db90ef9ad8f5e8ac2783dacbae09e3053f54cdc28a0533674215c7ca24e46"

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
