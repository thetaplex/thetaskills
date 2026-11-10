# Dependabot

`check.sh` lists the ecosystems it detected on the `dependabot` line. It maps files to ecosystems like this:

| File | Ecosystem |
|---|---|
| `package.json` | `npm` |
| `uv.lock` | `uv` |
| `requirements*.txt`, or `pyproject.toml` without `uv.lock` | `pip` |
| `Cargo.toml` | `cargo` |
| `go.mod` | `gomod` |
| `Gemfile` | `bundler` |
| `composer.json` | `composer` |
| `pom.xml` | `maven` |
| `build.gradle`, `build.gradle.kts` | `gradle` |
| `*.csproj` | `nuget` |
| `Dockerfile` | `docker` |
| `.github/workflows/` | `github-actions` |

Before writing the file, check each name against GitHub's current list: https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference#package-ecosystem-

Write one entry per ecosystem and directory (the folder holding the manifest; `/` for `github-actions`):

```yaml
version: 2
updates:
  - package-ecosystem: "<ecosystem>"
    directory: "/<dir>"
    schedule:
      interval: "weekly"
```

If most of the owner's other repos (`peers` lines) use a different interval or group updates, match them and say so.
