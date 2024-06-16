// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum AccountScreen: StoryboardType {
    internal static let storyboardName = "AccountScreen"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Self.self)

    internal static let accountScreen = SceneType<AccountViewController>(storyboard: Self.self, identifier: "accountScreen")
  }
  internal enum ChatScreen: StoryboardType {
    internal static let storyboardName = "ChatScreen"

    internal static let chatScreen = SceneType<ChatViewController>(storyboard: Self.self, identifier: "chatScreen")
  }
  internal enum ContactScreen: StoryboardType {
    internal static let storyboardName = "ContactScreen"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Self.self)

    internal static let contactScreen = SceneType<ContactViewController>(storyboard: Self.self, identifier: "contactScreen")
  }
  internal enum ConversationScreen: StoryboardType {
    internal static let storyboardName = "ConversationScreen"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Self.self)

    internal static let conversationScreen = SceneType<ConversationViewController>(storyboard: Self.self, identifier: "conversationScreen")
  }
  internal enum DGTabBarScreen: StoryboardType {
    internal static let storyboardName = "DGTabBarScreen"

    internal static let initialScene = InitialSceneType<DGTabBarViewController>(storyboard: Self.self)

    internal static let tbscreeen = SceneType<DGTabBarViewController>(storyboard: Self.self, identifier: "TBSCREEEN")
  }
  internal enum Introduction: StoryboardType {
    internal static let storyboardName = "Introduction"

    internal static let initialScene = InitialSceneType<IntroductionFirstViewController>(storyboard: Self.self)

    internal static let introducitonForthVC = SceneType<IntroductionForthViewController>(storyboard: Self.self, identifier: "introducitonForthVC")

    internal static let introductionFirstVC = SceneType<IntroductionFirstViewController>(storyboard: Self.self, identifier: "introductionFirstVC")

    internal static let introductionSecondVC = SceneType<IntroductionSecondViewController>(storyboard: Self.self, identifier: "introductionSecondVC")

    internal static let introductionThirdVC = SceneType<IntroductionThirdViewController>(storyboard: Self.self, identifier: "introductionThirdVC")
  }
  internal enum LandingScreen: StoryboardType {
    internal static let storyboardName = "LandingScreen"

    internal static let initialScene = InitialSceneType<LandingScreenViewController>(storyboard: Self.self)

    internal static let landingScreenVC = SceneType<LandingScreenViewController>(storyboard: Self.self, identifier: "landingScreenVC")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: Self.self)
  }
  internal enum MailVerification: StoryboardType {
    internal static let storyboardName = "MailVerification"

    internal static let initialScene = InitialSceneType<MailVerificationViewController>(storyboard: Self.self)

    internal static let mailVerificationVC = SceneType<MailVerificationViewController>(storyboard: Self.self, identifier: "mailVerificationVC")

    internal static let verifiedVC = SceneType<VerifiedViewController>(storyboard: Self.self, identifier: "verifiedVC")
  }
  internal enum NewConversation: StoryboardType {
    internal static let storyboardName = "NewConversation"

    internal static let newConversationVC = SceneType<NewConversationViewController>(storyboard: Self.self, identifier: "newConversationVC")
  }
  internal enum SignInScreen: StoryboardType {
    internal static let storyboardName = "SignInScreen"

    internal static let signInVC = SceneType<SignInViewController>(storyboard: Self.self, identifier: "signInVC")
  }
  internal enum SignUpScreen: StoryboardType {
    internal static let storyboardName = "SignUpScreen"

    internal static let initialScene = InitialSceneType<SignUpViewController>(storyboard: Self.self)

    internal static let signUpVC = SceneType<SignUpViewController>(storyboard: Self.self, identifier: "signUpVC")
  }
  internal enum Splash: StoryboardType {
    internal static let storyboardName = "Splash"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Self.self)

    internal static let splashVC = SceneType<SplashViewController>(storyboard: Self.self, identifier: "splashVC")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
