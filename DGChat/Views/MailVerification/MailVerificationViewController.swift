//
//  MailVerificationViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 27/09/23.
//

import UIKit
import Firebase

class MailVerificationViewController: UIViewController {
    
    @IBOutlet var mailVerificationSentNotificationLabel: UILabel!
    @IBOutlet var userEmailAddressLabel: UILabel!
    @IBOutlet var verifyButton: GradientButton!
    @IBOutlet var signOutButton: GradientButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configTheme()
    }
    
    private func configTheme() {
        mailVerificationSentNotificationLabel.isHidden = true
        userEmailAddressLabel.text = FirebaseAuth.Auth.auth().currentUser?.email ?? "No address found"
    }
    
    private func checkingVerificaitonResponse() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { timer in
            Auth.auth().currentUser?.reload(completion: { _ in
                
                print("USER: \(Auth.auth().currentUser?.email ?? "")")
                print("Verification: \(Auth.auth().currentUser?.isEmailVerified ?? false)")
                
                if (Auth.auth().currentUser?.isEmailVerified ?? false) {
                    timer.invalidate()
                    let verifiedVC = StoryboardScene.MailVerification.verifiedVC.instantiate()
                    verifiedVC.modalPresentationStyle = .fullScreen
                    self.present(verifiedVC, animated: true)
                }
            })
        }
    }
    
    @IBAction func didTapSignOutButton(_ sender: GradientButton) {
        FirebaseHelper.shared.signOutUser()
        
        let landingScreenVC =  StoryboardScene.LandingScreen.landingScreenVC.instantiate()
        landingScreenVC.modalPresentationStyle = .fullScreen
        self.present(landingScreenVC, animated: true)
    }
    
    
    @IBAction func didTapVerificationButton(_ sender: GradientButton) {
        showLoader()
        
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if let error = error {
                self.hideLoader()
                Alert().showWarningAlert(withTitle: "Verificaiton Failed", withMessage: "Try after some time", inView: self, time: 2.0, completionHandler: nil)
            } else {
                self.hideLoader()
                self.signOutButton.isHidden = true
                self.verifyButton.isHidden = true
                self.mailVerificationSentNotificationLabel.isHidden = false
                self.checkingVerificaitonResponse()
            }
        }
    }
    
}
