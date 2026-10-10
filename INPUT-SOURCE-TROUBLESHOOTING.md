# Amar Avro Keyboard — Input Source troubleshooting

## Why it can be missing

macOS caches Text Input Sources. Copying the app bundle into `~/Library/Input Methods/` is necessary, but on some macOS versions the list may not refresh until the input source is registered and the user logs out/in. Older duplicate bundles can also make the system pick up the wrong copy.

## Recovery steps

1. Quit System Settings.
2. Keep one copy only at `~/Library/Input Methods/Amar Avro Keyboard.app`.
3. Launch that installed app once. It now calls `TISRegisterInputSource`, then looks up the source by the app bundle identifier and attempts to enable/select it.
4. Log out of macOS and log back in; if necessary restart.
5. Open System Preferences → Keyboard → Input Sources → + (macOS Monterey 12). Check Bangla and Other.
6. If it remains missing, collect the Console logs containing `Amar Avro Keyboard` and verify the built app's `Contents/Info.plist` has `InputMethodConnectionName`, `InputMethodServerControllerClass`, `TISIntendedLanguage`, and `tsInputMethodCharacterRepertoireKey`.

## Important

A successful GitHub Actions build only confirms the app compiled and was packaged; it cannot confirm registration on every Mac. Test the final artifact on the target macOS version. Ad-hoc signed builds may also have different Gatekeeper behavior from Developer ID signed and notarized builds.
