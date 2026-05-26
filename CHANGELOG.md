# Changelog

All notable changes to PairNest will be documented in this file.

## [Unreleased]

### Changed

- Pinned Android build inputs required for reproducible local and CI builds.
- Added GitHub tag-based Android release workflow and documented versioning rules.

## [0.1.1] - 2026-05-26

### Changed

- Stabilized the Android GitHub Actions release workflow for tag-based publishing.
- Vendored the `nearby_connections` dependency to avoid upstream Android build instability.
- Standardized the initial release process around ABI-split APK assets and documented version governance.

## [0.1.0] - 2026-05-26

### Added

- Flutter MVP scaffold for PairNest.
- Local-first storage with SQLCipher-backed SQLite event log.
- Couple binding flow with QR invite generation and QR scan join.
- Home dashboard with:
  - love day count,
  - today status,
  - recent notes,
  - growth metrics,
  - anniversary reminder.
- Timeline with text, mood, tags, and image notes.
- Growth system with check-in reward accumulation.
- Anniversary create + countdown rendering.
- Nearby sync flow:
  - device discovery,
  - connection establishment,
  - missing-event sync,
  - duplicate detection,
  - image file transfer and event image-path backfill,
  - sync status metrics.
- Runtime permission handling for camera/gallery/nearby bluetooth-location stack.
- Developer quality gates:
  - local hooks (`pre-commit`, `pre-push`),
  - audit scripts,
  - CI quality workflow.
- Sync unit tests and MVP acceptance checklist.

### Quality

- `flutter analyze` passing.
- `flutter test` passing.
- `./scripts/mvp_self_check.sh` passing.
