# GitHits Homebrew tap

Install [githits-scan](https://github.com/githits-com/githits-scan):

```sh
brew install githits-com/tap/githits-scan
```

Bottles target macOS 15 Apple Silicon and Linux x86_64/ARM64. Other platforms,
including Intel macOS, build from source with Homebrew's Rust build dependency.
On Intel macOS that can also require building Rust and LLVM from source; this
fallback is not exercised by the bottle CI matrix.

## Release delivery

A tagged Scan release opens a formula version-update PR using the tap's GitHub
App. The `brew test-bot` workflow builds and tests all three bottle targets.
After it succeeds, the publisher runs automatically **only** when:

- The PR author is `githits-homebrew-tap-bumper[bot]`.
- The open PR targets `main` in this repository and still has the tested head SHA.
- The only changed file is the modified `Formula/githits-scan.rb`.

The publisher is triggered directly by `workflow_run`, not by a bot-applied
label: labels written with `GITHUB_TOKEN` would not trigger another workflow.
Selection uses read-only API calls and trusted `main` code. The publishing job
uses the tap's `GITHUB_TOKEN` and standard `brew pr-pull`, which applies the
selected PR and evaluates its formula Ruby with the write token. Automatic
publication therefore trusts the App and tap writers; the manual path trusts
the maintainer's review. PR workflows and auxiliary scripts are not executed.
`--head-sha` verifies the selected commit again before bottle publication.

Human and Dependabot PRs are never published automatically. After reviewing
successful CI and all three bottle artifacts, a maintainer applies `pr-pull`.
The initial 0.3.0 PR uses this manual path. Manual workflow dispatch also accepts
a PR number and optional reviewed head SHA. Skipped formula builds fail checks;
maintenance PRs with no formula changes need no bottles. `pr-pull` does not itself
enforce the complete platform set, so the manual path needs that review.
`pr-pull` closes published PRs; their branches can remain because automatic
branch deletion applies to GitHub merges.

Keep Homebrew's default publishing permissions: no PR-required/checks ruleset and
no App bypass on `main`. A separate no-bypass rule blocks force-push and deletion
for everyone. No App key or publishing environment is needed in this tap. The
App is used only by Scan's release workflow to open bump PRs; its variable and
secret belong to Scan's `homebrew-tap` environment. See Scan's
[release process](https://github.com/githits-com/githits-scan/blob/main/docs/implementation/release-process.md).
There is no scheduled version updater in this tap.

Tap content is licensed under [Apache-2.0](LICENSE).
See [Homebrew's tap documentation](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap).
