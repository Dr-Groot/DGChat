//
//  AccountViewController.swift
//  DGChat
//  Created by Aman Pratap Singh on 28/09/23.
//

import UIKit
import Firebase
import SkeletonView
import Kingfisher

class AccountViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        configTheme()
        setInitialProfilePictureView()
        setImageSekeltonView()
        setUserName()
    }
    
    private func configTheme() {
        self.navigationItem.title = "ACCOUNT"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(questionMarkTapped))
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        let profileImageGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(profileImageButtonTapped))
        profileImageGestureRecogniser.numberOfTapsRequired = 1
        self.profileImageView.addGestureRecognizer(profileImageGestureRecogniser)
        self.profileImageView.isUserInteractionEnabled = true
    }
    
    private func setImageSekeltonView() {
        self.profileImageView.isSkeletonable = true
    }
    
    private func setInitialProfilePictureView() {
        let pictureDownloadURL = UserDefaults.standard.string(forKey: L10n.profilePictureKey) ?? ""
        profileImageView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.white), transition: .crossDissolve(0.25))
        
        profileImageView.kf.setImage(with: URL(string: pictureDownloadURL)) { result in
            switch result {
            case .success:
                self.profileImageView.hideSkeleton(transition: .crossDissolve(0.5))
                print("Success: Profile Image Setup")
            case .failure:
                self.profileImageView.hideSkeleton(transition: .crossDissolve(0.5))
                print("Failure: Profile Image Setup")
            }
        }
    }
    
    private func setUserName() {
        self.userNameLabel.text = UserDefaults.standard.string(forKey: L10n.userNameKey)
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
    
    
    @objc func questionMarkTapped() {
        let logOutAlert = UIAlertController(title: "Log Out", message: "Are you sure want to log out?", preferredStyle: .actionSheet)
        logOutAlert.addAction(UIAlertAction(title: "Confirm", style: .destructive,handler: { _ in
            FirebaseHelper.shared.signOutUser()
            
            let landingPageVC = StoryboardScene.LandingScreen.landingScreenVC.instantiate()
            landingPageVC.modalPresentationStyle = .fullScreen
            self.present(landingPageVC, animated: true)
        }))
        logOutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(logOutAlert, animated: true)
    }

}

extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
                self.profileImageView.image = image
//              UPLOAD IMAGE
                guard let image = self.profileImageView.image,
                      let data = image.pngData() else {
                    return
                }
                let filename = CommonHelper.shared.getPictureFileName()
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
            picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
