class Aisi < Formula
  desc "CLI tool for managing AI agent resources across multiple editors"
  homepage "https://github.com/rosseca/aisi"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.5.0/aisi_0.5.0_darwin_amd64.tar.gz"
      sha256 "9f3dc69dbc7fe5b84f546b6b0707925a71f0dd20b25a29b7975564e494a89610"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.5.0/aisi_0.5.0_darwin_arm64.tar.gz"
      sha256 "1fe7e4ca7891daa0ec786c376927755d6b20fec5b49f4441422da4b0c3a23f1e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.5.0/aisi_0.5.0_linux_amd64.tar.gz"
      sha256 "a57ef300f4e0f0a907d1874496687805d0ccff8e8579fdf4c78e994609d447b9"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.5.0/aisi_0.5.0_linux_arm64.tar.gz"
      sha256 "2fa4d0dd046b49359d779aeaed67c5e889bffd09858e1c8272ad828bba8c1349"
    end
  end

  def install
    bin.install "aisi"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aisi --version")
  end
end
