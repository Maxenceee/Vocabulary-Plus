//
//  ToResultTransition.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 03/04/2021.
//

import Foundation
import UIKit

class ResultControllerTransition: UIStoryboardSegue {

    override func perform() {
        fade()
    }
    
    func fade() {
        let toViewController = self.destination
        let fromViewController = self.source
        
        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center
        
        toViewController.view.alpha = 0
        toViewController.view.transform = CGAffineTransform(scaleX: 0.005, y: 0.005)
        toViewController.view.layer.cornerRadius = 150
        toViewController.view.center = originalCenter
        
        fromViewController.view.alpha = 1
        fromViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        fromViewController.view.layer.cornerRadius = 0
        fromViewController.view.center = originalCenter
        
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { [self] in
            toViewController.view.alpha = 1
            toViewController.view.transform = CGAffineTransform.identity
            toViewController.view.layer.cornerRadius = 0
            
            fromViewController.view.alpha = 0
            fromViewController.view.transform = CGAffineTransform(scaleX: 0.005, y: 0.005)
            fromViewController.view.layer.cornerRadius = 150
        }, completion: { succes in
            toViewController.modalPresentationStyle = .fullScreen
            fromViewController.present(toViewController, animated: false, completion: nil)
            
        })
    }
}

class LauchScreenTransition: UIStoryboardSegue {

    override func perform() {
        fade()
    }
    
    func fade() {
        let toViewController = self.destination
        let fromViewController = self.source
        
        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center
        
        toViewController.view.alpha = 0
        toViewController.view.center = originalCenter
        
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveEaseInOut, animations: { [self] in
            toViewController.view.alpha = 1
        }, completion: { succes in
            toViewController.modalPresentationStyle = .fullScreen
            fromViewController.present(toViewController, animated: false, completion: nil)
            
        })
    }
}
