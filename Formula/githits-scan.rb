class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "7b8b9855ccb87cc75cea8ee447071e82214ea07e4dfca594622e39bd8b3eb817"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/githits-com/homebrew-tap/releases/download/githits-scan-0.3.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a05f9649ca0a7b26320286212ae1ddeef514107eb050f34cc9550e9fb8fffc95"
    sha256 cellar: :any,                 arm64_linux:   "04552f6b17462177ec8cfaa7ed5ecaa16be5c081c45f2c8c805043018fa0c6fe"
    sha256 cellar: :any,                 x86_64_linux:  "8ee7f1d947a4cb926dfc1c57db02cced4136b7d5e223bbc4d2401fbc012dab12"
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
