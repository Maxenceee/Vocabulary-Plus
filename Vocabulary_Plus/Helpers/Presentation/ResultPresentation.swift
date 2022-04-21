//
//  ResultPresentation.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 30/04/2021.
//

import Foundation
import UIKit

class ResultPresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        if LanguagesList.errorsList.count != 0 {
            return CGRect(origin: CGPoint(x: 10, y: self.containerView!.frame.height * 0.2 - 10), size: CGSize(width: self.containerView!.frame.width - 20, height: self.containerView!.frame.height * 0.8))
        } else {
            return CGRect(origin: CGPoint(x: 10, y: self.containerView!.frame.height * 0.58 - 10),
                 size: CGSize(width: self.containerView!.frame.width - 20, height: self.containerView!.frame.height *
                              0.42))
        }
    }
    
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
        self.blurEffectView.alpha = 0.5
        }, completion: {
            (UIViewControllerTransitionCoordinatorContext) in
        })
    }

    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
        self.blurEffectView.alpha = -1.0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.removeFromSuperview()
        })
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners(.allCorners, radius: 40)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }

    @objc func dismissController(){
//        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
