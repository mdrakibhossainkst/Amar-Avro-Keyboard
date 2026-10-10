# Input Source compatibility note

This customized fork intentionally preserves the upstream input-method bundle identifier
`app.aminul.inputmethod.AvroKeyboard` and original `LSBackgroundOnly` plist value type.
These are kept stable to reduce changes to macOS Text Input Services registration behavior.
The visible product/app name remains Amar Avro Keyboard.

Important: after building, install the app into `~/Library/Input Methods/` and launch that
installed copy (not the app running from the mounted DMG). Then log out and log back in.
On macOS Monterey, open System Preferences > Keyboard > Input Sources and use `+`.
