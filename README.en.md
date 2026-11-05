# XKeyLite

<div align="center">
  <img src="xkey.png" alt="XKeyLite Logo" width="128" height="128">

  **Vietnamese Input Method for lazy people**

  [![macOS](https://img.shields.io/badge/macOS-12.0+-green.svg)](https://www.apple.com/macos/)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
</div>

---

[![Tiếng Việt](https://img.shields.io/badge/Language-Ti%E1%BA%BFng_Vi%E1%BB%87t-red)](README.md)
[![English](https://img.shields.io/badge/Language-English-green)](README.en.md)

---

## What is XKeyLite?

XKeyLite is a trimmed version of [XKey](https://github.com/xmannv/xkey).

XKey is powerful, but it has too many settings. This project is for lazy people like me who do not want to read and check pages of long, complicated config. Turn it on and type Vietnamese.

XKeyLite keeps the Vietnamese typing core of XKey and removes almost everything else.

## What is left

The Settings window has 4 sections.

**Cơ bản (General)**
- Hotkey to turn Vietnamese on/off. Supports key combos, modifier-only hotkeys (Ctrl+Shift...), and the Fn/🌐 Globe key.
- Undo Vietnamese typing (`tiếng` → `tieesng`). The default key is Esc. You can choose a single Shift tap instead.
- Input method: Auto-detect, Telex, VNI, Simple Telex 1, Simple Telex 2.
- Launch at login.

**Nâng cao (Advanced)**
- Capitalize the first letter of a sentence.
- Custom consonants (Z, F, W, J...).
- Spell check with auto-restore (experimental). Includes a personal dictionary.
- Smart Switch: remembers Vietnamese/English per app.

**Input Sources**
- Turn XKeyLite on or off for each macOS input source.

**Giới thiệu (About)**

Menu bar icon: **V** means Vietnamese, **E** means English. Click the icon to switch Vietnamese on/off or open Settings.

Fixed settings (you do not choose them):
- Code table: Unicode.
- Old accent style: `òa`, `úy`.
- UI language: follows macOS.
- Built-in fixes for Google Docs, Telegram Web and some other web apps: always on.

## What is removed

Quick typing (Quick Telex), Macro, Translation, Convert tool, Excluded apps, non-Unicode code tables, the floating toolbar, XKeyIM (Input Method Kit), custom per-app rules, Remote Desktop, the Debug window, Backup/iCloud Sync, appearance options, and auto-update.

These features are switched off in the code, not only hidden in the UI.

XKeyLite does not update itself. It never installs full XKey over itself.

## Tip: use Caps Lock to switch Vietnamese

1. System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys: set **Caps Lock** to **🌐 Globe**.
2. System Settings → Keyboard: set **"Press 🌐 key to"** to **"Do Nothing"**.
3. XKeyLite → Cơ bản → toggle hotkey: click the list button and choose **Fn**.

Tap Caps Lock to switch V ↔ E.

## Install

There is no release yet. Build it from source.

### Requirements

- macOS 12.0 or later.
- Xcode.
- Accessibility permission for XKeyLite.

### Build

1. Create a local code signing certificate (once per Mac). Without it, macOS forgets the Accessibility permission after every build.

   ```bash
   cd "$(mktemp -d)"
   printf '[req]\ndistinguished_name=dn\nx509_extensions=ext\nprompt=no\n[dn]\nCN=XKeyLite Local Signing\n[ext]\nbasicConstraints=critical,CA:false\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=critical,codeSigning\n' > cert.cnf
   /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 3650 -config cert.cnf
   /usr/bin/openssl pkcs12 -export -inkey key.pem -in cert.pem -name "XKeyLite Local Signing" -out id.p12 -passout pass:temp
   security import id.p12 -k ~/Library/Keychains/login.keychain-db -P temp -T /usr/bin/codesign
   rm key.pem id.p12
   ```

2. Open `XKey.xcodeproj` in Xcode.
3. Choose the **XKey** scheme and click Run. Debug builds sign with the "XKeyLite Local Signing" certificate.
4. Grant permission: System Settings → Privacy & Security → Accessibility → turn on XKey.

The Release config and `build_release.sh` still belong to the original XKey. They do not work yet.

### Settings location

`~/Library/Application Support/XKey-Lite/`

## Thanks

- [XKey](https://github.com/xmannv/xkey), the original project. XKeyLite forked from XKey 1.2.25. If you find it useful, support the XKey author: Settings → Giới thiệu → **Support Original Author**.
- XKey was inspired by OpenKey and Unikey.

## License

MIT. See [LICENSE](LICENSE).
