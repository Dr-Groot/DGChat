//
//  VerifiedViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 27/09/23.
//

import UIKit

class VerifiedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func didTapLetsGoButton(_ sender: GradientButton) {
        let dgTabBarVC = StoryboardScene.DGTabBarScreen.tbscreeen.instantiate()
        dgTabBarVC.modalPresentationStyle = .fullScreen
        self.present(dgTabBarVC, animated: true)
    }
    
}
