# Amar Avro Keyboard for macOS

A customized macOS Bangla input method featuring Avro Phonetic, Probhat and Unijoy layouts, with Unicode or ANSI (Bijoy) output.

**Customized branding and project maintenance:** Md Rakib Hossain  
**Version:** 1.0.0  
**Minimum macOS:** 12 Monterey (as inherited from the upstream project)

> **Important attribution and license notice:** Amar Avro Keyboard is a customized fork of the open-source iAvro / Avro Keyboard project. The original keyboard engine and other upstream contributions are not claimed as original work by the maintainer of this fork. Copyright notices and the `LICENSE` file are retained. The project includes code under the Mozilla Public License 1.1 (MPL 1.1); read `LICENSE` before redistributing.

## Branding changes in this fork
- Product display name: **Amar Avro Keyboard**
- App icon and input-menu icon: supplied Amar Avro logo
- Credits screen: customized to identify Md Rakib Hossain as the maintainer of this branded fork and acknowledge the upstream project
- Bundle identifier: `com.rakibhossain.amaravrokeyboard`
- GitHub Actions build workflow updated to use the renamed scheme and app bundle

## Features
- Avro Phonetic, Probhat and Unijoy keyboard layouts
- Unicode and ANSI (Bijoy-font) output
- Optional dictionary suggestions and auto-correct
- Native macOS Input Method integration

## Build on GitHub
1. Create a new GitHub repository and upload the contents of this project folder.
2. Open **Actions** and enable workflows if GitHub asks.
3. Open the **Build** workflow and click **Run workflow** for a test build, or push a version tag such as `v1.0.0`.
4. Open the completed workflow run and download the generated build artifacts.
5. To sign and notarize releases for distribution, configure the Apple Developer ID and App Store Connect secrets listed in `.github/workflows/build.yml`.

The project uses Xcode and builds on GitHub's macOS runners. Building or signing has not been run in this environment, so verify the workflow result on GitHub before distributing.

## Build locally on a Mac
1. Install Xcode 16 or later.
2. Open `AvroKeyboard.xcodeproj` in Xcode.
3. Select the **Amar Avro Keyboard** scheme.
4. Choose **Product → Build**.
5. The resulting app is named `Amar Avro Keyboard.app`.

Command line:

```sh
xcodebuild -project AvroKeyboard.xcodeproj \
  -scheme "Amar Avro Keyboard" \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY=- build
```

## Install the input method
1. Build the app or download a build artifact from GitHub Actions.
2. Copy `Amar Avro Keyboard.app` to `~/Library/Input Methods/`.
3. Log out and log back in if macOS does not immediately detect the input method.
4. Open **System Preferences → Keyboard → Input Sources (macOS Monterey 12)**, add Bangla if needed, and select **Amar Avro Keyboard**.
5. Use its Preferences menu to choose the layout and output options.

If another Avro-based input method is installed, remove its input-source entry first to avoid duplicate entries. Do not delete unrelated input methods.

## Upstream acknowledgement
This fork builds on work from OmicronLab and contributors to iAvro / Avro Keyboard, including the original Avro project and its community-maintained macOS fork. The Avro name and related trademarks may belong to their respective owners; this fork's custom logo is supplied by its maintainer. This project is independent and is not an official OmicronLab release.

## License
See [`LICENSE`](LICENSE) for the complete MPL 1.1 terms. Preserve this file and the applicable source-file copyright notices when redistributing.


## Customized UI and build workflow

The Preferences window has a refreshed layout for General and AutoCorrect settings, with larger spacing and clearer headings. The app icon, menu icon, and website icon assets use the Amar Avro Keyboard branding. GitHub Actions calls packaging scripts through `bash` so the DMG step does not fail when executable file permissions are not preserved. See `BUILD-FIXES.md` for build and signing notes.

### If Amar Avro Keyboard does not appear in Input Sources

1. Quit System Settings. Confirm `Amar Avro Keyboard.app` is inside `~/Library/Input Methods/` (not in a nested folder).
2. Open the installed app once from that folder. The app now attempts to register and enable its Text Input Source at launch, including when it was copied there manually.
3. Log out of macOS and log back in. Then open **System Preferences → Keyboard → Input Sources → + (macOS Monterey 12)** and look under **Bangla** or **Other**. The exact category can vary by macOS release.
4. If it still does not appear, remove older duplicate copies from `~/Library/Input Methods/`, keep only the latest app, restart the Mac, and try again.

The first successful build does not guarantee macOS has refreshed its cached input-source list.

