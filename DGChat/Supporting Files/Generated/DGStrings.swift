// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Enter Email
  internal static var enterEmailText: String { return L10n.tr("Localizable", "enterEmailText") }
  /// Enter First Name
  internal static var enterFirstNameText: String { return L10n.tr("Localizable", "enterFirstNameText") }
  /// Enter Last Name
  internal static var enterLastNameText: String { return L10n.tr("Localizable", "enterLastNameText") }
  /// Enter Password
  internal static var enterPasswordText: String { return L10n.tr("Localizable", "enterPasswordText") }
  /// Forgot Password
  internal static var forgotPasswordText: String { return L10n.tr("Localizable", "forgotPasswordText") }
  /// profile_picture_key
  internal static var profilePictureKey: String { return L10n.tr("Localizable", "profilePictureKey") }
  /// email
  internal static var selfEmailAddressKey: String { return L10n.tr("Localizable", "selfEmailAddressKey") }
  /// name
  internal static var userNameKey: String { return L10n.tr("Localizable", "userNameKey") }
  /// UserOnboarded
  internal static var userOnboardedKey: String { return L10n.tr("Localizable", "userOnboardedKey") }
  /// Welcome me again !!
  internal static var welcomeMeAgainText: String { return L10n.tr("Localizable", "welcomeMeAgainText") }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    return String(
        format: NSLocalizedString(key, tableName: table, comment: key),
        arguments: args)
  }
  static func lntr(locale: String, _ table: String, _ key: String, _ args: CVarArg...) -> String {
    guard let path = Bundle.main.path(forResource: locale, ofType: "lproj"),
          let languageBundle = Bundle(path: path) else {
      return tr(table, key, args)
    }
    return String(
        format: languageBundle.localizedString(forKey: key, value: nil, table: table),
        args
    )
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type

