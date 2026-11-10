# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `open-source-ready`: checks that private vulnerability reporting is on, and offers to turn it on.

## [0.2.0] - 2026-11-10

### Added

- `open-source-ready` skill: gets a GitHub repo ready to make public using its owner's conventions, and stops before the visibility change.
- `vibe-scaffold` docs: a "Without an agent" section on running `setup.sh` and `bootstrap.sh` directly.

## [0.1.1] - 2026-11-10

### Changed

- `vibe-scaffold`: when the project is in another folder, the agent ends with the exact `cd … && <agent>` command to continue there.
- `vibe-scaffold` setup installs the latest release of superpowers, ponytail and rtk (when built with cargo) instead of their latest commit.

## [0.1.0] - 2026-11-09

First release.

### Added

- `vibe-scaffold` skill: scaffolds a repo with git, OpenSpec specs and an `AGENTS.md` wired for superpowers, ponytail, rtk and headroom, then plans the first feature.
- Manifests for pi, Claude Code, Codex and the `.agents` marketplace, and `scripts/install.sh` for other agents.

[Unreleased]: https://github.com/thetaplex/thetaskills/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/thetaplex/thetaskills/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/thetaplex/thetaskills/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/thetaplex/thetaskills/releases/tag/v0.1.0
