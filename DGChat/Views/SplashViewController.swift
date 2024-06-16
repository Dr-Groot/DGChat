//
//  SplashViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 22/09/23.
//

import UIKit
import Lottie
import Firebase

class SplashViewController: UIViewController {
    
    @IBOutlet var splashLottieView: LottieAnimationView!
/// Two boolean value to check 2 are true then we can move ahead.
    var splashTimer: Bool = false
    var userReloaded: Bool = false
    var isUserOnBoarded = UserDefaults().value(forKey: L10n.userOnboardedKey) ?? false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSplashTimer()
        prepareUserReload()
        setUpLottieAnimation()
    }
    
    private func setUpLottieAnimation() {
        splashLottieView.backgroundColor = .clear
        splashLottieView.contentMode = .scaleAspectFit
        splashLottieView.loopMode = .loop
        splashLottieView.animationSpeed = 1.0
        splashLottieView.play()
        
    }
    
    private func prepareSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.splashTimer = true
            self.checkResponses()
        }
    }
    
    private func prepareUserReload() {
        if  Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { _ in
                print("USER: \(Auth.auth().currentUser?.email ?? "")")
                print("Verification: \(Auth.auth().currentUser?.isEmailVerified ?? false)")
                self.userReloaded = true
                self.checkResponses()
            })
        } else {
            self.userReloaded = true
            self.checkResponses()
        }
    }
    
    private func checkResponses() {
        if splashTimer && userReloaded {
            if Auth.auth().currentUser != nil {
                Auth.auth().currentUser!.isEmailVerified
                ? moveToTabBarScreen()
                : moveToVerificationScreen()
            } else {
                isUserOnBoarded as! Bool
                ? moveToLandingPage()
                : moveToIntroduction()
            }
        }
    }
    
    private func moveToIntroduction() {
        let introFirstVC = StoryboardScene.Introduction.introductionFirstVC.instantiate()
        introFirstVC.modalPresentationStyle = .fullScreen
        self.present(introFirstVC, animated: true)
    }
    
    private func moveToLandingPage() {
        let landingScreenVC = StoryboardScene.LandingScreen.landingScreenVC.instantiate()
        landingScreenVC.modalPresentationStyle = .fullScreen
        self.present(landingScreenVC, animated: true)
    }
    
    private func moveToVerificationScreen() {
        let mailVerifyVC = StoryboardScene.MailVerification.mailVerificationVC.instantiate()
        mailVerifyVC.modalPresentationStyle = .fullScreen
        self.present(mailVerifyVC, animated: true)
    }
    
    private func moveToTabBarScreen() {
        let dgTabBarVC = StoryboardScene.DGTabBarScreen.tbscreeen.instantiate()
        dgTabBarVC.modalPresentationStyle = .fullScreen
        self.present(dgTabBarVC, animated: true)
    }

}
