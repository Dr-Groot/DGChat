//
//  UIViewControllerExtension.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 27/09/23.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController {
    func showLoader(indicatorColor: UIColor = UIColor.systemMint) {
        let activityData = ActivityData(type: .circleStrokeSpin, color: indicatorColor)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    func hideLoader() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
}
