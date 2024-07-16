//
//  ShimmerView.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/15/24.
//

import UIKit

class ShimmerView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShimmer()
    }
    
    private func setupShimmer() {
        backgroundColor = .white
        
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor(white: 0.5, alpha: 1.0).cgColor,
            UIColor(white: 0.4, alpha: 1.0).cgColor,
            UIColor(white: 0.6, alpha: 1.0).cgColor
        ]
        
        gradientLayer.locations = [0.4, 0.5, 0.6]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 1.5
        animation.fromValue = -frame.width
        animation.toValue = frame.width
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: -frame.width, y: 0, width: 3 * frame.width, height: frame.height)
    }
}
