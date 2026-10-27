cask "kilo-proxy" do
  arch arm: "arm64", intel: "amd64"

  version "0.67.8"
  sha256 arm:   "fc95a7c791d35ecbac5efcb765b93c0d69075b297b3509ef8bb08fa9f08e9777",
         intel: "a4ddfbec5a2a2d51473bcf6cde2dc81cb913da95c9aa22606b786ec5c0a0828c"

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
