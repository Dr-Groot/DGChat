//
//  IntroductionSecondViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 25/09/23.
//

import UIKit
import Lottie

class IntroductionSecondViewController: UIViewController {

    @IBOutlet var chatLottieAnimationView: LottieAnimationView!
    @IBOutlet var first2Dot: UIView!
    @IBOutlet var second2Dot: UIView!
    @IBOutlet var third2Dot: UIView!
    @IBOutlet var forth2Dot: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLottieAnimationView()
        configDependency()
        setSwipeGestureRecognizer()
    }
    
    private func configDependency() {
        first2Dot.layer.cornerRadius = (first2Dot.frame.size.width < first2Dot.frame.size.height) ? first2Dot.frame.size.width / 2.0 : first2Dot.frame.size.height / 2.0
        second2Dot.layer.cornerRadius = (second2Dot.frame.size.width < second2Dot.frame.size.height) ? second2Dot.frame.size.width / 2.0 : second2Dot.frame.size.height / 2.0
        third2Dot.layer.cornerRadius = (third2Dot.frame.size.width < third2Dot.frame.size.height) ? third2Dot.frame.size.width / 2.0 : third2Dot.frame.size.height / 2.0
        forth2Dot.layer.cornerRadius = (forth2Dot.frame.size.width < forth2Dot.frame.size.height) ? forth2Dot.frame.size.width / 2.0 : forth2Dot.frame.size.height / 2.0
    }

    private func setupLottieAnimationView() {
        chatLottieAnimationView.backgroundColor = .clear
        chatLottieAnimationView.contentMode = .scaleAspectFit
        chatLottieAnimationView.loopMode = .loop
        chatLottieAnimationView.animationSpeed = 1.0
        chatLottieAnimationView.play()
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
                let introThirdVC =  StoryboardScene.Introduction.introductionThirdVC.instantiate()
                introThirdVC.modalTransitionStyle = .flipHorizontal
                introThirdVC.modalPresentationStyle = .fullScreen
                self.present(introThirdVC, animated: true)
            case .right:
                self.dismiss(animated: true)
            default:
                break
            }
        }
    }
}
