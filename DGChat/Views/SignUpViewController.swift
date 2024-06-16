//
//  SignUpViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 27/09/23.
//

import UIKit
import TransitionButton
import Combine

class SignUpViewController: UIViewController {
    
    @IBOutlet var submitButton: TransitionButton!
    @IBOutlet var backImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var FirstNameTextField: UITextField!
    @IBOutlet var LastNameTextField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    
    var observers: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTheme()
        configDependency()
        keyboardHandler()
    }
    
    private func configTheme() {
        setSubmitButton()
        
        let getBackGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(getBackToVC))
        getBackGestureRecogniser.numberOfTapsRequired = 1
        self.backImageView.addGestureRecognizer(getBackGestureRecogniser)
        self.backImageView.isUserInteractionEnabled = true
        
        profileImageView.image = UIImage(named: "profileImagePlaceholder")
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        let profileImageGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(profileImageButtonTapped))
        profileImageGestureRecogniser.numberOfTapsRequired = 1
        self.profileImageView.addGestureRecognizer(profileImageGestureRecogniser)
        self.profileImageView.isUserInteractionEnabled = true
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.enterEmailText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.enterPasswordText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        FirstNameTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.enterFirstNameText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
        LastNameTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.enterLastNameText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        
    }
    
    private func configDependency() {}
        
    private func setSubmitButton() {
        submitButton.setTitle("Submit", for: .normal)
        submitButton.layer.borderWidth = 2
        submitButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc func getBackToVC() {
        self.dismiss(animated: true)
    }
    
    @objc func profileImageButtonTapped() {
        let profileImageSelectionAlert = UIAlertController(title: "Select Profile Image", message: "Please select any options.", preferredStyle: .actionSheet)
        
        let galleryAlert = UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            imagePickerVC.allowsEditing = true
            self.present(imagePickerVC, animated: true)
        })
        
        let cameraAlert = UIAlertAction(title: "Camera", style: .default) { _ in
            let cameraPickerVC = UIImagePickerController()
            cameraPickerVC.sourceType = .camera
            cameraPickerVC.allowsEditing = true
            cameraPickerVC.delegate = self
            self.present(cameraPickerVC, animated: true)
        }
        
        let removePhotoAlert = UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
            self.profileImageView.image = UIImage(named: "profileImagePlaceholder")
        }
        
        let cancelAlert = UIAlertAction(title: "Cancel", style: .destructive)
        
        profileImageSelectionAlert.addAction(galleryAlert)
        profileImageSelectionAlert.addAction(cameraAlert)
        if self.profileImageView.image != UIImage(named: "profileImagePlaceholder") {
            profileImageSelectionAlert.addAction(removePhotoAlert)
        }
        profileImageSelectionAlert.addAction(cancelAlert)
        
        self.present(profileImageSelectionAlert, animated: true)
    }
    
    @IBAction func didTapSubmitButton(_ sender: TransitionButton) {
        self.dismissKeyboard()
        sender.startAnimation()

        if (!FirstNameTextField.text!.isEmpty && !LastNameTextField.text!.isEmpty) {
            if (!emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
                
                DatabaseManager.shared.userExsitsCheck(with: emailTextField.text!, completion: { exsits in
                    guard exsits else {
                        stopAnimatingWithAlert(alertMessage: "User already exsits, Try Sign In !")
                        return
                    }
                    FirebaseHelper.shared.accountCreate(email: self.emailTextField.text!, password: self.passwordTextField.text!)
                })
            } else {
                stopAnimatingWithAlert(alertMessage: "Please Enter Valid Mail or Password")
            }
        } else {
            stopAnimatingWithAlert(alertMessage: "Please Enter Valid Fist or Last Name")
        }
        
        FirebaseHelper.shared.signUpObserver
            .sink(receiveValue: { [self] value in
                if value {
//                  SAVE USER DETAILS AS AUTH ACCOUNT CREATED
                    let chatUser = ChatAppUser(
                        firstName: FirstNameTextField.text!,
                        lastName: LastNameTextField.text!,
                        emailAddress: emailTextField.text!)
                    DatabaseManager.shared.getUserName()
                    DatabaseManager.shared.insertUser(with: chatUser,completion: { success in
                        if success {
//                            UPLOAD IMAGE
                            guard let image = self.profileImageView.image,
                                  let data = image.pngData() else {
                                return
                            }
                            let filename = chatUser.profilePicutreFileName
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                switch result {
                                case .success(let downloadUrl):
                                    UserDefaults.standard.set(downloadUrl, forKey: L10n.profilePictureKey)
                                    print("Succesfully Uploaded image, Download URL: \(downloadUrl)")
                                case .failure:
                                    print("Error uploading image")
                                }
                            })
                        }
                    })
                    
                    //                  MOVE TO MAIL VERIFICATION SCREEN
                    DispatchQueue.main.async(execute: { () -> Void in
                        sender.stopAnimation(animationStyle: .expand, completion: {
                            let mailVerifyVC = StoryboardScene.MailVerification.mailVerificationVC.instantiate()
                            mailVerifyVC.modalPresentationStyle = .fullScreen
                            self.present(mailVerifyVC, animated: true)
                        })
                    })
                } else {
                    stopAnimatingWithAlert(alertMessage: "Invalid Entries")
                }
            }).store(in: &observers)
        
        func stopAnimatingWithAlert(alertMessage: String) {
            Alert().showWarningAlert(withTitle: "", withMessage: alertMessage, inView: self, time: 2.0, completionHandler: nil)
            DispatchQueue.main.async(execute: { () -> Void in
                sender.stopAnimation(animationStyle: .expand, completion: {
                    self.setSubmitButton()
                })
            })
        }
    }
    

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
                self.profileImageView.image = image
            }
            picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController {
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
                self.view.frame.origin.y -= 100
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
