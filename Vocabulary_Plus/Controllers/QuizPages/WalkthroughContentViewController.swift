//
//  WalkthroughContentViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 03/04/2021.
//

import UIKit
import Lottie

class WalkthroughContentViewController: UIPageViewController {
    
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        
//        view.addSubview(blurView)
        
        view.addSubview(titleLabel)
        view.addSubview(ordersLabel)
        view.addSubview(sentenseLabel)
        
        initShadowsAndColors()
        
        setupLayout()
    }
    
    func initShadowsAndColors() {
        titleLabel.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
        ordersLabel.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
        sentenseLabel.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initShadowsAndColors()
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "Title", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 20) as Any])
        
        label.attributedText = attributedText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var ordersLabel: UILabel = {
        let label = UILabel()
        label.text = "Orders"
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var sentenseLabel: UILabel = {
        let label = UILabel()
        label.text = "To translate"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.contentMode = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupLayout() {
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        ordersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        ordersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        ordersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        ordersLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        sentenseLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        sentenseLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        sentenseLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        sentenseLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
}
