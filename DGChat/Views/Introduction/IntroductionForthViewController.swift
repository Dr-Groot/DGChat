//
//  IntroductionForthViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 25/09/23.
//

import UIKit

class IntroductionForthViewController: UIViewController {
    
    @IBOutlet var first4View: UIView!
    @IBOutlet var second4View: UIView!
    @IBOutlet var third4View: UIView!
    @IBOutlet var forth4View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configDependency()
        setSwipeGestureRecognizer()
    }
   
    private func configDependency() {
        first4View.layer.cornerRadius = (first4View.frame.size.width < first4View.frame.size.height) ? first4View.frame.size.width / 2.0 : first4View.frame.size.height / 2.0
        second4View.layer.cornerRadius = (second4View.frame.size.width < second4View.frame.size.height) ? second4View.frame.size.width / 2.0 : second4View.frame.size.height / 2.0
        third4View.layer.cornerRadius = (third4View.frame.size.width < third4View.frame.size.height) ? third4View.frame.size.width / 2.0 : third4View.frame.size.height / 2.0
        forth4View.layer.cornerRadius = (forth4View.frame.size.width < forth4View.frame.size.height) ? forth4View.frame.size.width / 2.0 : forth4View.frame.size.height / 2.0
    }
    
    private func setSwipeGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeLeft.direction = .left
            self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeRight.direction = .right
            self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .left:
                let landingScreenVC =  StoryboardScene.LandingScreen.landingScreenVC.instantiate()
                landingScreenVC.modalTransitionStyle = .flipHorizontal
                landingScreenVC.modalPresentationStyle = .fullScreen
                self.present(landingScreenVC, animated: true)
            case .right:
                self.dismiss(animated: true)
            default:
                break
            }
        }
    }
}
