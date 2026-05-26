# PairNest

[中文](README.md) | English

PairNest is a local-first Flutter app for couples to record shared memories, grow together, and sync directly between devices without relying on a centralized backend.

[![Flutter Quality Gate](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/flutter_quality.yml/badge.svg)](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/flutter_quality.yml)
[![Android Release](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/android_release.yml/badge.svg)](https://github.com/Wh1teJ0ker/PairNest/actions/workflows/android_release.yml)

## Overview

PairNest is built around five product constraints:

- local-first by default
- private shared space for couples
- event-log driven state model
- offline-first recording flow
- Android-first direct sync MVP

This repository currently contains:

- the MVP baseline
- local audit and release gates
- GitHub Actions quality workflows
- Android Release automation

## Highlights

- QR-based pairing and join flow
- Relationship dashboard with days count, status, notes, growth, and anniversaries
- Timeline for note, mood, tag, and image memories
- Growth system for check-ins and shared tasks
- Anniversary countdown flow
- Nearby direct sync
- SQLCipher-backed local persistence
- Secure key handling with `flutter_secure_storage`

## Tech Stack

- Flutter
- Riverpod
- SQLCipher / SQLite
- Nearby Connections
- GitHub Actions

## Architecture

- append-only event log
- local read projections for UI rendering
- sync by exchanging missing events
- privacy boundary kept on-device plus explicit nearby transfer

Representative events:

- `BIND_PAIR`
- `ADD_NOTE`
- `ADD_IMAGE`
- `ADD_MOOD`
- `ADD_SCORE`
- `ADD_ANNIVERSARY`
- `DAILY_CHECKIN`

## Repository Layout

```text
lib/                      Flutter application source
test/                     unit and widget tests
docs/                     product, acceptance, versioning, and policy docs
scripts/                  audit, validation, and release scripts
.github/workflows/        CI and release automation
third_party/              vendored build-critical dependencies
android/                  Android host project
ios/                      iOS host project
```

## Getting Started

### Requirements

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

### Build

```bash
flutter build apk --release
```

## Quality Gates

```bash
flutter analyze
flutter test
./scripts/release_check.sh
```

## Release Rules

The canonical app version is defined in `pubspec.yaml`.

- semantic version: `MAJOR.MINOR.PATCH`
- build number: `+BUILD`
- Git tag format: `vMAJOR.MINOR.PATCH`

Current baseline:

- app version: `0.1.1+2`
- current tag: `v0.1.1`

Detailed release governance is documented in [`docs/VERSIONING.md`](docs/VERSIONING.md).

## Changelog Policy

Every code update must include an auditable change description.

See:

- [`CHANGELOG.md`](CHANGELOG.md)
- [`docs/CHANGELOG_POLICY.md`](docs/CHANGELOG_POLICY.md)
- [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Contributing

Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before submitting changes.
