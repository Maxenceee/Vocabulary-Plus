//
//  AnimatedColoredBackground.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 19/04/2021.
//

import Foundation
import UIKit

class AnimatedColoredBackground: UIView, CAAnimationDelegate {
    
    private var gradientLayer: CAGradientLayer!
    
    public var start: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            updateGradientStart()
        }
    }
    public var end: CGPoint = CGPoint(x: 1, y: 1) {
        didSet {
            updateGradientEnd()
        }
    }
    
    var startPoint = CGPoint(x: -5, y: -5)//CGPoint(x: Int.random(in: -10...0), y: Int.random(in: -10...0))
    var endPoint = CGPoint(x: 5, y: 5)
    
    var randColors = [] as [CGColor]
    let colors = [UIColor.systemRed.cgColor, UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor, UIColor.systemTeal.cgColor, UIColor.systemGreen.cgColor, UIColor.systemOrange.cgColor, UIColor.systemPurple.cgColor, UIColor.systemYellow.cgColor, UIColor.systemIndigo.cgColor]
    
    override func draw(_ rect: CGRect) {
        guard layer.sublayers == nil else {
            return
        }
        
        for _ in 0...10 {
            randColors.append(UIColor.random().cgColor)
        }
        
        gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        gradientLayer.colors = colors.shuffled()
        gradientLayer.frame = rect
        
        layer.addSublayer(gradientLayer)
        
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.bounds
        
        self.addSubview(blurView)
        /*
        let animationX = CABasicAnimation(keyPath: "startPoint.x")
//        animationS.fromValue = gradientLayer.startPoint
        animationX.toValue = CGFloat.random(in: -5...0.5)
        animationX.autoreverses = false
        animationX.delegate = self
//        animationX.fillMode = .forwards
        animationX.isAdditive = true
        animationX.isCumulative = true
        animationX.repeatCount = Float.infinity
        animationX.duration = 2
        let animationY = CABasicAnimation(keyPath: "startPoint.y")
        animationY.toValue = CGFloat.random(in: -5...0.5)
        animationY.autoreverses = false
        animationY.delegate = self
//        animationY.fillMode = .forwards
        animationY.isAdditive = true
        animationY.isCumulative = true
        animationY.repeatCount = Float.infinity
        animationY.duration = 2
 
        gradientLayer.add(animationX, forKey: "startPoint.x")
        gradientLayer.add(animationY, forKey: "startPoint.y")
        
         */
 
//        var i = 0
//        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { (t) in
//            _ = CGPoint(x: CGFloat.random(in: -5...0.5), y: CGFloat.random(in: -5...0.5))
//            UIView.animate(withDuration: 1, delay: 0, options: [], animations: { [self] in
//                gradientLayer.startPoint.x = CGFloat.random(in: -5...5)
//                gradientLayer.startPoint.y = CGFloat.random(in: -5...5)
//                i+=1
//            }, completion: { [self] _ in
//                print("gradient updated \(i)")
//            })
//        })
    }
    
    private func updateGradientStart() {
        gradientLayer.startPoint = start
//        print("gradient updated")
    }
    
    private func updateGradientEnd() {
        gradientLayer.endPoint = end
//        print("gradient updated")
    }
}
