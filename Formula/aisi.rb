class Aisi < Formula
  desc "CLI tool for managing AI agent resources across multiple editors"
  homepage "https://github.com/rosseca/aisi"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.1.0/aisi_0.1.0_darwin_amd64.tar.gz"
      sha256 "88e4c496c69837c3a8aab754372c2d43be17d2f9bfa64752d55e9fe13ba8b00d"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.1.0/aisi_0.1.0_darwin_arm64.tar.gz"
      sha256 "b9fade681d8e31756db77fafa6f46082a3573fee8576cb1539297445e40e87c8"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.1.0/aisi_0.1.0_linux_amd64.tar.gz"
      sha256 "8859144ed96ec34ddbdf46b378fae2f2619c7649b5d9c2ba83e1389b1c1303f0"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.1.0/aisi_0.1.0_linux_arm64.tar.gz"
      sha256 "6cdfa9df3316440f4e3324e0ef91cd22653c03d3d6b0e1f12d162244ae54ec4e"
    end
  end

  def install
    bin.install "aisi"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aisi --version")
  end
end
