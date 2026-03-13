class Aisi < Formula
  desc "CLI tool for managing AI agent resources across multiple editors"
  homepage "https://github.com/rosseca/aisi"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.2.0/aisi_0.2.0_darwin_amd64.tar.gz"
      sha256 "ddaedcc73941ba8425afa664695674a43099163c709012410f5be6d7bbf95977"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.2.0/aisi_0.2.0_darwin_arm64.tar.gz"
      sha256 "f45a7136c7f7ae938907018af03a61862da3d9e1e2e4ff329bb1d1c4b2f8743a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.2.0/aisi_0.2.0_linux_amd64.tar.gz"
      sha256 "7d172a749b5fe3088fd042440a32ce0bd49ccabeee09a9ce696fcd6bec2b6e99"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.2.0/aisi_0.2.0_linux_arm64.tar.gz"
      sha256 "60485c1c182b8923a7b4d28a93481006bcb7977b779c13f4081fb141fa35a801"
    end
  end

  def install
    bin.install "aisi"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aisi --version")
  end
end
