class GithitsScan < Formula
  desc "Generate SBOMs, audit dependencies, and check licenses"
  homepage "https://github.com/githits-com/githits-scan"
  url "https://github.com/githits-com/githits-scan/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "2828f591490f238bd9826391bb72effe2fe97973ab6c2009c03eb7a341d53ef5"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/githits-com/homebrew-tap/releases/download/githits-scan-0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dd0c1de317e6eeb56ac38ef064f6bd99541858315fe0233b5f6ba3305e7a90c1"
    sha256 cellar: :any,                 arm64_linux:   "f293107998145c809b75c5bdde7af6340bcbb102228cd173041cb5adf23c466c"
    sha256 cellar: :any,                 x86_64_linux:  "4078c57853b39cf7e5bc468d11eb520002bcce00dae5f7a900f64c4450738fda"
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
