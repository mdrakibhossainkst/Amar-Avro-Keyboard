# Amar Avro Keyboard — Build fixes

## Fix for `scripts/make-dmg.sh: Permission denied`

GitHub-hosted runners may check out or receive the repository without the executable bit preserved (especially when files were uploaded through the GitHub web UI). The workflow now invokes shell scripts explicitly with `bash`:

- `bash scripts/make-dmg.sh ...`
- `bash scripts/notarize.sh ...`

The script files are also marked executable in the repository. This avoids relying on file-mode preservation.

## Run a build

1. Push the extracted project contents to a GitHub repository (do not upload only the ZIP).
2. Open **Actions → Build → Run workflow**.
3. Wait for the Apple Silicon, Intel, and Universal jobs.
4. Download the matching `.dmg` and `.zip` artifacts from each successful job.

## Signing note

Without Apple Developer ID and App Store Connect secrets, the workflow produces an ad-hoc-signed build. It can be useful for testing, but Gatekeeper may warn when installing it on another Mac. A Developer ID certificate and notarization credentials are required for a signed and notarized public release.

## Validation note

The shell scripts were checked with `bash -n`. This package has not been compiled with Xcode in this environment; the first GitHub Actions run remains the authoritative build test.

## Input Source registration fix

The installer now attempts to register, enable, and select the input source both after copying the app and when the app is already installed in `~/Library/Input Methods/`. This addresses the case where a user manually copied the bundle and the old installer silently skipped registration. The build workflow also checks required Input Method Kit metadata. If macOS still has a cached source list, log out and back in after launching the installed copy once; see `INPUT-SOURCE-TROUBLESHOOTING.md`.

## Preferences and branding

The Preferences window now uses the supplied Amar Avro Keyboard icon and branded General, AutoCorrect, and Credits layouts. App, menu, toolbar, and website icons are generated from the supplied logo at their declared sizes. Original license and copyright notices remain available in `LICENSE`.
