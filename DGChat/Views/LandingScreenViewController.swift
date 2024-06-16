//
//  LandingScreenViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 25/09/23.
//

import UIKit
import Lottie

class LandingScreenViewController: UIViewController {
    
    @IBOutlet var welcomeMeAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setWelcomeMeAgainButton()
        UserDefaults().set(true, forKey: L10n.userOnboardedKey)
    }
    
    private func setWelcomeMeAgainButton() {
        let welcomeButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let welcomeAttributeString = NSMutableAttributedString(
            string: L10n.welcomeMeAgainText,
            attributes: welcomeButtonAttributes
        )
        welcomeMeAgainButton.setAttributedTitle(welcomeAttributeString, for: .normal)
    }
    
    @IBAction func didTapSignInButton(_ sender: GradientButton) {
        let signInVC = StoryboardScene.SignInScreen.signInVC.instantiate()
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true)
    }
    
    @IBAction func didTapSignUpButton(_ sender: GradientButton) {
        let signUpVC = StoryboardScene.SignUpScreen.signUpVC.instantiate()
        signUpVC.modalPresentationStyle = .fullScreen
        self.present(signUpVC, animated: true)
    }
    
    @IBAction func didTapWelcomeMeAgainButton(_ sender: UIButton) {
        UserDefaults().set(false, forKey: L10n.userOnboardedKey)
        
        let introductionVC = StoryboardScene.Introduction.introductionFirstVC.instantiate()
        introductionVC.modalPresentationStyle = .fullScreen
        self.present(introductionVC, animated: true)
    }

}
