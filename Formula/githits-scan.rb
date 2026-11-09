class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "a61e8f969b462597bc08efe35b6bcb0566a823b0a9df97ededc84356b336c09f"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/githits-com/homebrew-tap/releases/download/githits-scan-0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "19d6f5b30f7119d710086857670595c142c94c131cb05eccc2eed629655ee34d"
    sha256 cellar: :any,                 arm64_linux:   "73613fe121b8d8b0d7a30c711a1937a0b461871345c1b7f50cf8c4a54c494e60"
    sha256 cellar: :any,                 x86_64_linux:  "9de50e7f3043a49a8416786bf1797c8905948b0eb884bdb82ccaf5c07119a0b0"
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
