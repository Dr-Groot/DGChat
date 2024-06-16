//
//  SignInViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 28/09/23.
//

import UIKit
import TransitionButton
import Combine
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: TransitionButton!
    @IBOutlet var backImageView: UIImageView!
    @IBOutlet var forgotPasswordButton: UIButton!
    
    var observers: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSignInButton()
        setForgotPasswordButton()
        configTheme()
        configForgotPasswordDependency()
        keyboardHandler()
    }
    
    private func configTheme() {
        let getBackGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(getBackToVC))
        getBackGestureRecogniser.numberOfTapsRequired = 1
        self.backImageView.addGestureRecognizer(getBackGestureRecogniser)
        self.backImageView.isUserInteractionEnabled =  true
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
    
    private func setSignInButton() {
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.layer.borderWidth = 2
        signInButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func getBackToVC() {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapSignInButton(_ sender: TransitionButton) {
        self.dismissKeyboard()
        sender.startAnimation()
        
        if (!emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
            FirebaseHelper.shared.signInToFirebase(email: emailTextField.text!, password: passwordTextField.text!)
        } else {
            stopAnimatingWithAlert(alertMessage: "Please Enter Valid Email or Password")
        }
        
        FirebaseHelper.shared.signInObserver
            .sink(receiveValue: { value in
                if value == self.emailTextField.text {
                    Auth.auth().currentUser?.reload(completion: { _ in
                        DatabaseManager.shared.getUserName()
                        if Auth.auth().currentUser?.isEmailVerified ?? false {
                            let dgTabBarVC = StoryboardScene.DGTabBarScreen.tbscreeen.instantiate()
                            dgTabBarVC.modalPresentationStyle = .fullScreen
                            self.present(dgTabBarVC, animated: true)
                        } else {
                            DispatchQueue.main.async(execute: { () -> Void in
                                sender.stopAnimation(animationStyle: .expand, completion: {
                                    let mailVerifyVC = StoryboardScene.MailVerification.mailVerificationVC.instantiate()
                                    mailVerifyVC.modalPresentationStyle = .fullScreen
                                    self.present(mailVerifyVC, animated: true)
                                })
                            })
                        }
                    })
                } else {
                    stopAnimatingWithAlert(alertMessage: "Wrong Credentials")
                }
            }).store(in: &observers)
        
        func stopAnimatingWithAlert(alertMessage: String) {
            Alert().showWarningAlert(withTitle: "", withMessage: alertMessage, inView: self, time: 2.0, completionHandler: nil)
            DispatchQueue.main.async(execute: { () -> Void in
                sender.stopAnimation(animationStyle: .expand, completion: {
                    self.setSignInButton()
                })
            })
        }
        
    }
    
    @IBAction func didTapForgotPasswordButton(_ sender: UIButton) {
        tappedForgotPasswordButton()
    }
    
}

// MARK: - Forgot Password Work
extension SignInViewController {
    private func setForgotPasswordButton() {
        let forgotPassButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.systemMint,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let forgotPassAttributeString = NSMutableAttributedString(
            string: L10n.forgotPasswordText,
            attributes: forgotPassButtonAttributes
        )
        forgotPasswordButton.setAttributedTitle(forgotPassAttributeString, for: .normal)
    }
    
    private func tappedForgotPasswordButton() {
        let forgotPassAlert = UIAlertController(title: "Forgot Password", message: "Please enter your email", preferredStyle: .alert)
        
        forgotPassAlert.addTextField{ username in
            username.text = ""
            username.placeholder = "Enter Email ..."
        }
        
        forgotPassAlert.addAction(UIAlertAction(title: "Request", style: .default, handler: { _ in
            let emailText = forgotPassAlert.textFields![0].text ?? ""
            FirebaseHelper.shared.forgotPasswordReset(email: emailText)
            self.showLoader()
            forgotPassAlert.dismiss(animated: true)
        }))
        forgotPassAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(forgotPassAlert, animated: true)
    }
    
    private func configForgotPasswordDependency() {
        FirebaseHelper.shared.forgotPasswordResetLinkSent.sink(receiveValue: { value in
            if value {
                self.hideLoader()
                self.showMessagePopUp(message: "Successfully send Reset link to you mail. Please check !")
            } else {
                self.hideLoader()
                self.showMessagePopUp(message: "Error! Unable to send Reset Link")
            }
        }).store(in: &observers)
    }
    
    private func showMessagePopUp(message: String) {
        let messageAlert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(messageAlert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            messageAlert.dismiss(animated: true)
        }
    }
    
}

extension SignInViewController {
    private func keyboardHandler() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIInputViewController.dismissKeyboard)
        )
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
             as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 70
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
