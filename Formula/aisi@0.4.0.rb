class AisiAT040 < Formula
  desc "CLI tool for managing AI agent resources across multiple editors"
  homepage "https://github.com/rosseca/aisi"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.0/aisi_0.4.0_darwin_amd64.tar.gz"
      sha256 "a96b12de545c9ec84313900edbe9a725684ecc5cb86bd624515cc1ee68964ca3"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.0/aisi_0.4.0_darwin_arm64.tar.gz"
      sha256 "7f0c1c7bda6a327ea7bb538cac8c76a9171608e52b156d967d18a8e9a82bec2c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.0/aisi_0.4.0_linux_amd64.tar.gz"
      sha256 "0b367a6bea82d9d1f4f1e6826078f9b77b53129c8ea50fc1b54eb056a6e6b7d0"
    end
    on_arm do
      url "https://github.com/rosseca/aisi/releases/download/v0.4.0/aisi_0.4.0_linux_arm64.tar.gz"
      sha256 "26e938a6b637afeeebcd98a0943ea2bd1eb6d400885c3e95382fe79a51378e3e"
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
