# GitHits Homebrew tap

Install [githits-scan](https://github.com/githits-com/githits-scan):

```sh
brew install githits-com/tap/githits-scan
```

Homebrew uses a matching bottle when available and otherwise builds from source
with Homebrew's Rust build dependency. Bottle builds target macOS 15 Apple Silicon
and Intel, and Linux x86_64 and ARM64.

## Maintenance

Formula pull requests run `brew test-bot` on each target and retain bottles as
workflow artifacts. After reviewing the PR and its successful checks, a maintainer
applies the `pr-pull` label. The publish workflow checks the labeled head SHA,
uploads bottles to this repository's GitHub Releases, and pushes the formula and
bottle metadata to `main` using this tap's `GITHUB_TOKEN`. Do not merge formula PRs
with GitHub's merge button before publishing their bottles.

The workflow can also be dispatched manually with the PR number and reviewed
head SHA. Publication and merging require maintainer approval.

Scan's release workflow opens version-update PRs using a GitHub App installed
only on this repository. Setup belongs to Scan's
[release process](https://github.com/githits-com/githits-scan/blob/main/docs/implementation/release-process.md).
There is no scheduled version updater in this tap.

Tap content is licensed under [Apache-2.0](LICENSE).
See [Homebrew's tap documentation](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap).
