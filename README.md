# PairNest

PairNest is a local-first Flutter app for couples to record shared memories, grow together, and sync data directly between devices without relying on a backend service.

[![Flutter Quality Gate](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/flutter_quality.yml/badge.svg)](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/flutter_quality.yml)
[![Android Release](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/android_release.yml/badge.svg)](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/android_release.yml)

## Overview

PairNest is built around one explicit product direction:

- local-first by default
- private couple space without a server dependency
- structured event log instead of ad hoc state mutation
- offline recording first, sync later
- Android-first MVP with direct device-to-device sync

This repository currently contains the first MVP baseline and the initial GitHub Actions release pipeline.

## Highlights

- QR-based couple binding and invite flow
- Home dashboard with relationship duration, recent memories, growth score, and anniversary reminders
- Timeline for notes, moods, tags, and image memories
- Growth system for check-ins and shared activity accumulation
- Anniversary creation with countdown rendering
- Nearby-based direct sync flow
- SQLCipher-backed local storage
- Secure local key handling with `flutter_secure_storage`
- Release automation through GitHub Actions

## Tech Stack

- Flutter
- Riverpod
- SQLCipher / SQLite
- Nearby Connections
- GitHub Actions

## Product Scope

Current MVP modules:

- `Bonding`
  QR invite generation and scanning
- `Home`
  relationship dashboard and reminder summary
- `Timeline`
  text, mood, tag, and image record flow
- `Growth`
  point accumulation and activity metrics
- `Anniversary`
  countdown and date reminders
- `Sync`
  local event-log replication over Nearby

## Architecture

Core design choices:

- Data is modeled as append-only events.
- Business views are derived from local projections.
- Sync exchanges missing events instead of merging mutable rows.
- Privacy boundary is device-local storage plus explicit nearby transfer.

Representative event types:

- `BIND_PAIR`
- `ADD_NOTE`
- `ADD_IMAGE`
- `ADD_MOOD`
- `ADD_SCORE`
- `ADD_ANNIVERSARY`
- `DAILY_CHECKIN`

## Repository Layout

```text
lib/                      Flutter app source
test/                     unit and widget tests
docs/                     product docs, UAT, traceability, versioning
scripts/                  audit, release, and acceptance scripts
.github/workflows/        CI and release automation
third_party/              vendored build fixes for unstable upstream plugins
android/                  Android host project
ios/                      iOS host project
```

## Screens And Experience

The current product experience centers on:

- shared private memory space
- low-friction capture
- glanceable relationship dashboard
- predictable local sync behavior

At this stage, the repo does not yet include polished marketing screenshots. The release pipeline is already in place, so the next practical step is adding curated screenshots and a short demo GIF to this README after device validation.

## Getting Started

### Prerequisites

- Flutter `3.44.0`
- Dart `3.12.0`
- Android SDK
- Android NDK `28.2.13676358`
- Java `17`

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run -d android
```

### Build Debug APK

```bash
flutter build apk --debug
```

### Build Release APK

```bash
flutter build apk --release
```

## Android Permissions

The app requests runtime permissions only when relevant flows are used:

- camera for QR binding
- gallery or storage access for image memories
- bluetooth, nearby devices, and location for direct sync

## Quality Gates

Local validation:

```bash
flutter analyze
flutter test
./scripts/release_check.sh
```

Additional acceptance tooling:

```bash
./scripts/mvp_self_check.sh
./scripts/final_acceptance_check.sh --skip-uat
```

## GitHub Actions

This repository currently ships with two workflows:

- `Flutter Quality Gate`
  format check, analyze, tests, and UAT script self-tests
- `Android Release`
  tag-triggered Android release build and GitHub Release asset upload

### Release Strategy

The canonical app version lives in `pubspec.yaml`.

- semantic version: `MAJOR.MINOR.PATCH`
- build number: `+BUILD`
- release tag format: `vMAJOR.MINOR.PATCH`

Current baseline:

- app version: `0.1.1+2`
- current tag: `v0.1.1`

Detailed rules are documented in `docs/VERSIONING.md`.

### Publish A Release

1. update `pubspec.yaml`
2. update `CHANGELOG.md`
3. push to `main`
4. create and push a tag such as `v0.1.1`
5. GitHub Actions builds the Android release artifact and publishes a GitHub Release

## Current Release Status

Verified locally:

- `flutter analyze`
- `flutter test`
- `assembleRelease`
- local release APK generation

Latest locally verified release artifact:

- `build/app/outputs/flutter-apk/app-release.apk`

## Documentation

- `docs/VERSIONING.md`
- `docs/NEARBY_DUAL_DEVICE_UAT.md`
- `docs/REQUIREMENT_TRACEABILITY_MATRIX.md`
- `docs/MVP_ACCEPTANCE_CHECKLIST.md`

## Roadmap

- add curated screenshots and demo media for release pages
- complete dual-device acceptance evidence and publish device matrix
- improve sync conflict visibility and retry UX
- package ABI-split Android release assets in GitHub Release
- extend the release pipeline with changelog-driven release notes

## Known Constraints

- `nearby_connections` is vendored in `third_party/` because the upstream Android build script is not stable enough for this toolchain baseline
- some release dependencies are sensitive to Maven TLS instability on this machine; the local release path has already been validated with cached artifacts
- iOS and macOS plugin ecosystems still emit Swift Package Manager support warnings for a few dependencies

## Contributing

The repo includes local hook and release scripts intended to keep changes auditable:

- `scripts/audit.sh`
- `scripts/release_check.sh`
- `.github/pull_request_template.md`

Keep changes scoped, run the quality gates, and treat event-log compatibility as a release concern.

## License

This project is currently private. No public license has been declared in the root repository yet.
