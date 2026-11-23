class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "5548da7f289e6abd4d50c2b670fd5aa4d703a8a900a21806de995321628ccef7"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/githits-com/homebrew-tap/releases/download/githits-scan-0.6.1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b0be4bf470011a8e9c2ed83d40fb3a4c793be7b2e24fd0234144ff460e12e482"
    sha256 cellar: :any,                 arm64_linux:   "90c586df90fbb846ee2af3130eb8d18546e8f5524fd2f5bc3fd3ec8815abde2a"
    sha256 cellar: :any,                 x86_64_linux:  "1561ebef3e19c56cdd82db8d0eaec281f2a24e4056b7cb9fd6e9bbc96ee13126"
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
