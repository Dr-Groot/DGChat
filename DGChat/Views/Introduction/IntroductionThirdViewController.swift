//
//  IntroductionThirdViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 25/09/23.
//

import UIKit
import Lottie

class IntroductionThirdViewController: UIViewController {
    
    @IBOutlet var locationLottieAnimationView: LottieAnimationView!
    @IBOutlet var first3View: UIView!
    @IBOutlet var second3View: UIView!
    @IBOutlet var third3View: UIView!
    @IBOutlet var forth4View: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configDependency()
        setupLottieAnimationView()
        setSwipeGestureRecognizer()
    }

    private func configDependency() {
        first3View.layer.cornerRadius = (first3View.frame.size.width < first3View.frame.size.height) ? first3View.frame.size.width / 2.0 : first3View.frame.size.height / 2.0
        second3View.layer.cornerRadius = (second3View.frame.size.width < second3View.frame.size.height) ? second3View.frame.size.width / 2.0 : second3View.frame.size.height / 2.0
        third3View.layer.cornerRadius = (third3View.frame.size.width < third3View.frame.size.height) ? third3View.frame.size.width / 2.0 : third3View.frame.size.height / 2.0
        forth4View.layer.cornerRadius = (forth4View.frame.size.width < forth4View.frame.size.height) ? forth4View.frame.size.width / 2.0 : forth4View.frame.size.height / 2.0
    }
    
    private func setupLottieAnimationView() {
        locationLottieAnimationView.backgroundColor = .clear
        locationLottieAnimationView.contentMode = .scaleAspectFit
        locationLottieAnimationView.loopMode = .loop
        locationLottieAnimationView.animationSpeed = 1.0
        locationLottieAnimationView.play()
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
                let introForthVC =  StoryboardScene.Introduction.introducitonForthVC.instantiate()
                introForthVC.modalPresentationStyle = .fullScreen
                introForthVC.modalTransitionStyle = .flipHorizontal
                self.present(introForthVC, animated: true)
            case .right:
                self.dismiss(animated: true)
            default:
                break
            }
        }
    }

}
