//
//  IntroductionFirstViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 22/09/23.
//

import UIKit
import Lottie

class IntroductionFirstViewController: UIViewController {
    
    @IBOutlet var swipeLottieAnimationView: LottieAnimationView!
    @IBOutlet var firstDot: UIView!
    @IBOutlet var secondDot: UIView!
    @IBOutlet var thirdDot: UIView!
    @IBOutlet var forthDot: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeLottieAnimation()
        setSwipeGestureRecognizer()
        configDependency()
    }
    
    private func configDependency() {
        firstDot.layer.cornerRadius = (firstDot.frame.size.width < firstDot.frame.size.height) ? firstDot.frame.size.width / 2.0 : firstDot.frame.size.height / 2.0
        secondDot.layer.cornerRadius = (secondDot.frame.size.width < secondDot.frame.size.height) ? secondDot.frame.size.width / 2.0 : secondDot.frame.size.height / 2.0
        thirdDot.layer.cornerRadius = (thirdDot.frame.size.width < thirdDot.frame.size.height) ? thirdDot.frame.size.width / 2.0 : thirdDot.frame.size.height / 2.0
        forthDot.layer.cornerRadius = (forthDot.frame.size.width < forthDot.frame.size.height) ? forthDot.frame.size.width / 2.0 : forthDot.frame.size.height / 2.0
    }
    
    private func setSwipeLottieAnimation() {
        swipeLottieAnimationView.backgroundColor = .clear
        swipeLottieAnimationView.contentMode = .scaleAspectFit
        swipeLottieAnimationView.loopMode = .loop
        swipeLottieAnimationView.animationSpeed = 0.75
        swipeLottieAnimationView.play()
    }
    
    private func setSwipeGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeLeft.direction = .left
            self.swipeLottieAnimationView.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .left:
                let introSecondVC =  StoryboardScene.Introduction.introductionSecondVC.instantiate()
                introSecondVC.modalTransitionStyle = .flipHorizontal
                introSecondVC.modalPresentationStyle = .fullScreen
                self.present(introSecondVC, animated: true)
            default:
                break
            }
        }
    }
    
}
