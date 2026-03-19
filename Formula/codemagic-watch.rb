class CodemagicWatch < Formula
  desc "Poll Codemagic builds, stream status changes, and react to failures"
  homepage "https://github.com/akmarinov/codemagic-watch"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/akmarinov/codemagic-watch/releases/download/v0.2.0/codemagic-watch_0.2.0_darwin_amd64.tar.gz"
      sha256 "4f9f85aadb2fdf9bc83ba9a5400e1863f82e2dda1e91da0538096cc71912ab02"
    end
    on_arm do
      url "https://github.com/akmarinov/codemagic-watch/releases/download/v0.2.0/codemagic-watch_0.2.0_darwin_arm64.tar.gz"
      sha256 "81a3bcf88558b9719180d991ff5ca8c098e329b5189668de1e4a01274e045952"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/akmarinov/codemagic-watch/releases/download/v0.2.0/codemagic-watch_0.2.0_linux_amd64.tar.gz"
      sha256 "dfeee4596485ae2fb1528367d5ac9c8bdcdbd934c8c1b115be4779e927ac6f46"
    end
    on_arm do
      url "https://github.com/akmarinov/codemagic-watch/releases/download/v0.2.0/codemagic-watch_0.2.0_linux_arm64.tar.gz"
      sha256 "516db421cadd11e37aaba1ac4030ad66d71ed7a835350422cfaf581d72768240"
    end
  end

  def install
    bin.install "codemagic-watch"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/codemagic-watch --version")
  end
end
