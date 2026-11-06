class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "7b8b9855ccb87cc75cea8ee447071e82214ea07e4dfca594622e39bd8b3eb817"
  license "Apache-2.0"

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
