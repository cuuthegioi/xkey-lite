# XKeyLite

<div align="center">
  <img src="xkey.png" alt="XKeyLite Logo" width="128" height="128">

  **Bộ gõ tiếng Việt cho người lười**

  [![macOS](https://img.shields.io/badge/macOS-12.0+-green.svg)](https://www.apple.com/macos/)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
</div>

---

[![Tiếng Việt](https://img.shields.io/badge/Language-Ti%E1%BA%BFng_Vi%E1%BB%87t-red)](README.md)
[![English](https://img.shields.io/badge/Language-English-green)](README.en.md)

---

## XKeyLite là gì?

XKeyLite là bản rút gọn của [XKey](https://github.com/xmannv/xkey).

XKey rất mạnh nhưng có quá nhiều setting. Dự án này dành cho người lười như tôi: không muốn đọc, không muốn kiểm tra setting dài và phức tạp.

XKeyLite giữ phần lõi gõ tiếng Việt của XKey và bỏ gần hết phần còn lại.

## Còn lại gì

Cửa sổ Settings chỉ còn 4 mục.

**Cơ bản**
- Phím tắt bật/tắt tiếng Việt. Hỗ trợ tổ hợp phím, phím modifier (Ctrl+Shift...), và phím Fn/🌐 Globe.
- Hoàn tác gõ tiếng Việt (`tiếng` → `tieesng`). Phím mặc định là Esc. Có thể chọn một lần nhấn Shift.
- Kiểu gõ: Tự nhận kiểu gõ, Telex, VNI, Simple Telex 1, Simple Telex 2.
- Khởi động cùng hệ thống.

**Nâng cao**
- Tự động viết hoa chữ đầu câu.
- Phụ âm tùy chỉnh (Z, F, W, J...).
- Kiểm tra chính tả và tự khôi phục (thử nghiệm). Có từ điển cá nhân.
- Smart Switch: nhớ tiếng Việt/tiếng Anh theo từng ứng dụng.

**Input Sources**
- Bật/tắt XKeyLite cho từng Input Source của macOS.

**Giới thiệu**

Biểu tượng trên thanh menu: **V** là tiếng Việt, **E** là tiếng Anh. Bấm vào biểu tượng để bật/tắt tiếng Việt hoặc mở Settings.

Các thiết lập cố định (bạn không cần chọn):
- Bảng mã: Unicode.
- Dấu kiểu cũ: `òa`, `úy`.
- Ngôn ngữ giao diện: theo macOS.
- Các bản sửa lỗi có sẵn cho Google Docs, Telegram Web và một số web app khác: luôn bật.

## Đã bỏ

Gõ nhanh (Quick Telex), Macro, Dịch thuật, Công cụ chuyển đổi, Loại trừ ứng dụng, Bảng mã khác Unicode, Thanh công cụ nổi, XKeyIM (Input Method Kit), quy tắc tùy chỉnh theo ứng dụng, Remote Desktop, Debug Window, Sao lưu/iCloud Sync, tùy chọn giao diện, và tự động cập nhật.

Các tính năng này đã tắt hẳn trong code, không chỉ bị ẩn khỏi giao diện.

XKeyLite không tự cập nhật. Nó không bao giờ tải bản XKey đầy đủ đè lên.

## Mẹo: dùng Caps Lock để chuyển tiếng Việt

1. System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys: đặt **Caps Lock** thành **🌐 Globe**.
2. System Settings → Keyboard: đặt **"Press 🌐 key to"** thành **"Do Nothing"**.
3. XKeyLite → Cơ bản → phím tắt bật/tắt: bấm nút danh sách và chọn **Fn**.

Bấm nhanh Caps Lock để chuyển V ↔ E.

## Cài đặt

### Cài qua Homebrew

```bash
brew install --cask cuuthegioi/tap/xkeylite
```

Sau khi cài:

1. XKeyLite chưa được Apple công chứng (notarize), nên macOS sẽ chặn lần mở đầu. Gỡ cờ quarantine sau mỗi lần cài hoặc nâng cấp:

   ```bash
   xattr -dr com.apple.quarantine /Applications/XKeyLite.app
   ```

2. Mở XKeyLite. Cấp quyền: System Settings → Privacy & Security → Accessibility → bật XKeyLite.

Nâng cấp: `brew upgrade --cask xkeylite`. Gỡ: `brew uninstall --cask xkeylite`.

XKeyLite không chạy cùng lúc với XKey bản đầy đủ. Hãy gỡ XKey trước.

### Build từ mã nguồn

Cần macOS 12.0 trở lên và Xcode.

1. Tạo chứng chỉ ký code trên máy (chỉ cần làm một lần). Nếu không có chứng chỉ này, macOS sẽ quên quyền Accessibility sau mỗi lần build.

   ```bash
   cd "$(mktemp -d)"
   printf '[req]\ndistinguished_name=dn\nx509_extensions=ext\nprompt=no\n[dn]\nCN=XKeyLite Local Signing\n[ext]\nbasicConstraints=critical,CA:false\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=critical,codeSigning\n' > cert.cnf
   /usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 3650 -config cert.cnf
   /usr/bin/openssl pkcs12 -export -inkey key.pem -in cert.pem -name "XKeyLite Local Signing" -out id.p12 -passout pass:temp
   security import id.p12 -k ~/Library/Keychains/login.keychain-db -P temp -T /usr/bin/codesign
   rm key.pem id.p12
   ```

2. Mở `XKey.xcodeproj` trong Xcode, chọn scheme **XKey** và bấm Run.
3. Cấp quyền: System Settings → Privacy & Security → Accessibility → bật XKeyLite.

Tạo bản phát hành: chạy `./build_release.sh`. Script tạo `Release/XKeyLite-<version>.zip` và cập nhật `sha256` trong `packaging/homebrew/xkeylite.rb`.

### Nơi lưu thiết lập

`~/Library/Application Support/XKey-Lite/`

## Cảm ơn

- [XKey](https://github.com/xmannv/xkey), bản gốc của XKeyLite. XKeyLite tách ra từ XKey 1.2.25. Nếu thấy hữu ích, hãy ủng hộ tác giả XKey: Settings → Giới thiệu → **Support Original Author**.
- XKey lấy cảm hứng từ OpenKey và Unikey.

## Giấy phép

MIT. Xem [LICENSE](LICENSE).
