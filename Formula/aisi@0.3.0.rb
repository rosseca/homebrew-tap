class AisiAT030 < Formula
  desc "CLI tool for managing AI agent resources across multiple editors"
  homepage "https://github.com/rosseca/aisi"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.3.0/aisi_0.3.0_darwin_amd64.tar.gz"
      sha256 "cc6f939b8a7c2c228574cefa23e6b98ca88e10b227c772b7c097b304f14cccec"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.3.0/aisi_0.3.0_darwin_arm64.tar.gz"
      sha256 "4caab9371471a74cdddcb49d366b8c1b73af4d59d77d671551f457004c8c7fae"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.3.0/aisi_0.3.0_linux_amd64.tar.gz"
      sha256 "243abb29a1616136a20ae177b5b9d27d76d89fb3f0b9e37f17fe034a6016846c"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.3.0/aisi_0.3.0_linux_arm64.tar.gz"
      sha256 "9a9e46a86648a3748d5c48a87138fab8ce361a0cfeb4f0a3598b044f51117f64"
    end
  end

  keg_only :versioned_formula

  def install
    bin.install "aisi"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aisi --version")
  end
end
