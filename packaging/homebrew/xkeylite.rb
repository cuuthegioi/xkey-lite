cask "xkeylite" do
  version "1.0.0"
  sha256 "ba465be612d16d6681b21f606eb28a6eac0c2d0a81bc5970035b915d9892896d"

  url "https://github.com/cuuthegioi/xkey-lite/releases/download/v#{version}/XKeyLite-#{version}.zip"
  name "XKeyLite"
  desc "Vietnamese input method for lazy people, trimmed from XKey"
  homepage "https://github.com/cuuthegioi/xkey-lite"

  conflicts_with cask: "xkey"
  depends_on macos: :monterey

  app "XKeyLite.app"

  uninstall quit: "com.cuuthegioi.XKeyLite"

  zap trash: [
    "~/Library/Application Support/XKey-Lite",
    "~/Library/Preferences/com.cuuthegioi.XKeyLite.plist",
  ]

  caveats <<~EOS
    XKeyLite is not signed with an Apple Developer ID, so macOS blocks it on first open.
    Remove the quarantine flag once after each install or upgrade:
      xattr -dr com.apple.quarantine #{appdir}/XKeyLite.app

    XKeyLite needs Accessibility permission to type Vietnamese:
      System Settings > Privacy & Security > Accessibility > turn XKeyLite on.
  EOS
end
