class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "5db51592b1441825a0a6d7ab2d471bb05ee53cb1e91b01fa6d09cd18337d321b"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/githits-com/homebrew-tap/releases/download/githits-scan-0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b93b291166631062f5be176617b4a6cefa8bb9b3f34d184095b2774f227c7b1b"
    sha256 cellar: :any,                 arm64_linux:   "53b7d8c2899952dfbd040906133f9bd8c3fd080a2b0c0686adda19b02d6ffcd7"
    sha256 cellar: :any,                 x86_64_linux:  "ad9070e4680f749ea592849ec0af1571fde912009dcd9f3d47615a5343717fa4"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/githits-scan --version")
    (testpath/"Cargo.lock").write("version = 4\n")
    inventory = JSON.parse(shell_output("#{bin}/githits-scan detect --json #{testpath}"))
    assert_equal "Cargo.lock", inventory.fetch("lockfiles").first.fetch("path")
    assert_equal "rust", inventory.fetch("lockfiles").first.fetch("ecosystem")
  end
end
