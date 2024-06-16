//
//  GradientButton.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 26/09/23.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {
    
    // Define the colors for the gradient
    @IBInspectable var startColor: UIColor = UIColor.red {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.yellow {
        didSet {
            updateGradient()
        }
    }
    
    // Create gradient layer
    let gradientLayer = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        // Set the gradient frame
        gradientLayer.frame = rect
        
        // Set the colors
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        // Gradient is linear from left to right
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        // Add gradient layer into the button
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Round the button corners
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
    }

    func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
