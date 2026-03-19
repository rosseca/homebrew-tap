class Aisi < Formula
  desc "CLI tool for managing AI agent resources across multiple editors"
  homepage "https://github.com/rosseca/aisi"
  version "0.4.1"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.1/aisi_0.4.1_darwin_amd64.tar.gz"
      sha256 "f92d358574a00dbff7fecf220f7aa86975251607023b73a5b9ffd38be8aac180"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.1/aisi_0.4.1_darwin_arm64.tar.gz"
      sha256 "4c2e5c72fa6669a134483ecd7baf17d856daecc1221ec6ced9e0bc738002bea6"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.1/aisi_0.4.1_linux_amd64.tar.gz"
      sha256 "cbbc9ed085503635ccb2102900d5d029ebced6c751b32d52afd5e598f1f332e3"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.1/aisi_0.4.1_linux_arm64.tar.gz"
      sha256 "36cffc8b7e0cfabe0db17ab4212e3a90f7b3492b2bc581030cb716315163a17b"
    end
  end

  def install
    bin.install "aisi"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aisi --version")
  end
end
