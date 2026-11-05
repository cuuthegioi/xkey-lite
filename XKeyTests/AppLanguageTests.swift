//
//  AppLanguageTests.swift
//  XKeyTests
//

import XCTest
@testable import XKey

class AppLanguageTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Ensure a clean slate — earlier test runs or unrelated code may have left
        // values in the standard domain that would skew assertions.
        UserDefaults.standard.removeObject(forKey: "appLanguage")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "appLanguage")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        super.tearDown()
    }

    // MARK: - applyLanguage

    // Sentinel locale never present in NSGlobalDomain — lets us detect whether
    // applyLanguage() removed our app-level override even though UserDefaults.standard
    // falls back to NSGlobalDomain for AppleLanguages (so reading nil after removal is
    // not reliable on a real system).
    private static let sentinelOverride = ["xx-XKey-test"]

    /// Lite always follows the macOS language, whatever an older build stored.
    func testApplyLanguageAlwaysClearsAppOverride() {
        for stored in ["vi", "en", "zh-Hans", "system", "garbage", nil] {
            UserDefaults.standard.set(Self.sentinelOverride, forKey: "AppleLanguages")
            UserDefaults.standard.set(stored, forKey: "appLanguage")

            AppLanguage.applyLanguage()

            let result = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
            XCTAssertNotEqual(result, Self.sentinelOverride, "stored appLanguage: \(stored ?? "nil")")
        }
    }

    func testInvalidRawValueReturnsNil() {
        XCTAssertNil(AppLanguage(rawValue: "invalid"))
    }

    // MARK: - localeIdentifier

    func testLocaleIdentifiers() {
        XCTAssertNil(AppLanguage.system.localeIdentifier)
        XCTAssertEqual(AppLanguage.vi.localeIdentifier, "vi")
        XCTAssertEqual(AppLanguage.en.localeIdentifier, "en")
        XCTAssertEqual(AppLanguage.zhHans.localeIdentifier, "zh-Hans")
    }

    // MARK: - Codable backward compatibility

    func testPreferencesDefaultLanguageIsSystem() {
        let prefs = Preferences()
        XCTAssertEqual(prefs.appLanguage, .system)
    }

    func testPreferencesRoundTripWithAppLanguage() throws {
        var prefs = Preferences()
        prefs.appLanguage = .zhHans

        let data = try JSONEncoder().encode(prefs)
        let decoded = try JSONDecoder().decode(Preferences.self, from: data)
        XCTAssertEqual(decoded.appLanguage, .zhHans)
    }
}
