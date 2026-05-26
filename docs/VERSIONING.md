# Versioning

PairNest uses a single source of truth for application versions: `pubspec.yaml`.

## Format

- App version: `MAJOR.MINOR.PATCH+BUILD`
- Example: `0.1.2+3`

Meaning:

- `MAJOR.MINOR.PATCH` is the user-facing semantic version.
- `BUILD` is the internal build number.

Platform mapping:

- Android: `versionName = MAJOR.MINOR.PATCH`, `versionCode = BUILD`
- iOS: `CFBundleShortVersionString = MAJOR.MINOR.PATCH`, `CFBundleVersion = BUILD`

## Rules

- Every GitHub release must bump `pubspec.yaml`.
- `BUILD` must be strictly increasing and must never be reset.
- Use semantic versioning for `MAJOR.MINOR.PATCH`:
  - breaking change: bump `MAJOR`
  - backward-compatible feature: bump `MINOR`
  - fix or small polish: bump `PATCH`
- Git tags use `vMAJOR.MINOR.PATCH`.
- The Git tag must match the build name in `pubspec.yaml`.

## Release flow

1. Update `version:` in `pubspec.yaml`.
2. Update `CHANGELOG.md`.
3. Commit and push to `main`.
4. Create and push a tag such as `v0.1.2`.
5. GitHub Actions builds release APKs from that tag and publishes them as release assets.

## Current baseline

- Current release version: `0.1.2+3`
- Current release tag: `v0.1.2`
