class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "2828f591490f238bd9826391bb72effe2fe97973ab6c2009c03eb7a341d53ef5"
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
