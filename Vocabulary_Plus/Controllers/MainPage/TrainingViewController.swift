//
//  TrainingViewController.swift
//  Voc+
//
//  Created by Maxence Gama on 02/03/2021.
//

import UIKit
import CoreData

class TrainingViewController: UIViewController, MainPageViewControllerDelegate {
    
    var walkthroughPageViewController: MainViewPageController?
    
    @IBOutlet var superContainerView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var graphInfoView: UIView!
    @IBOutlet var GIBottomAnchor: NSLayoutConstraint!
    @IBOutlet var containerBottomAnchor: NSLayoutConstraint!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    private var models = [LangData]()
    
    var BGColorTimer = Timer()

    var isViewDidSeen = false
    var isGraphInfoViewShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        
        startButtonsStackView.addArrangedSubview(startButton)
        view.addSubview(customModelButton)
        view.addSubview(tagModelButton)
        
        initInfoView()
        
//        containerView.backgroundColor = .clear
        
//        containerView.insertSubview(imageView, at: 0)
//        BGAnimatedColored.alpha = 0.8
//        containerView.insertSubview(BGAnimatedColored, at: 0)
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 0.5
        blurView.frame = view.bounds
        
//        containerView.insertSubview(blurView, at: 0)
        
//        initObservers()
//        animateEndBG()
        
        self.superContainerView.transform = CGAffineTransform(scaleX: 0, y: 0)
//        self.superContainerView.roundCorners(.allCorners, radius: 40)
        self.graphInfoView.layer.cornerRadius = 40
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [self] in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.containerView.roundCorners(.allCorners, radius: 40)
                superContainerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                setUpSahdows()
            })
        })
        view.backgroundColor = UIColor(named: "BackGroundColor")
        
        progressView.dropShadow(.black, opacity: 0.2, width: 0, height: 0, radius: 10, cornerR: 0)
        
        UserDefaults.standard.removeObject(forKey: "customTempContentList")
        
        setUpLayout()
        setUpSahdows()
        
        startButton.addBlurEffect()
        
        tabBarController?.tabBar.tintColor = UIColor(hexString: "#E74C3C")
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customStartButton(_:)), name: Notification.Name(rawValue: "customStartButtonForCustomContent"), object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setUpSahdows()
        updateGIViewBeforeAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllItems()
        if superContainerView.transform == CGAffineTransform(scaleX: 0, y: 0) {
            moveContentView(toindex: 0)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: { [self] in
                superContainerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { _ in
                if self.isViewDidSeen == true {
                    self.moveContentView(toindex: 2)
                } else {
                    self.isViewDidSeen = true
                }
            })
        }
        /*
        let uds = UserDefaults.standard.object(forKey: "isCustomContent") as? Bool
        if uds != nil && uds == true {
            print("custom content")
            let attributedText = NSMutableAttributedString(string: "Start\n(custom selection)", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 20) as Any])
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: 7,length: 18))
            
            startButton.setAttributedTitle(attributedText, for: .normal)
        } else {
            print("default")
            let attributedText = NSMutableAttributedString(string: "Start\n(custom selection)", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 20) as Any])
            
            startButton.setAttributedTitle(attributedText, for: .normal)
        }*/
    }
    
    let isDefault: Bool = true
    
    @objc func didTapContentViewInfoButton() {
        switch isDefault {
        case true:
            didTapContentViewInfoButtonFlipAnim()
        case false:
            didTapContentViewInfoButtonFoldAnim()
        }
    }
    
    @objc func didTapContentViewInfoButtonFlipAnim() {
        if isGraphInfoViewShowing {
            closeInfoViewButton.isEnabled = false
            GIBottomAnchor.constant = containerView.frame.size.height - 100
            UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseInOut, animations: { [self] in
                blurView.frame = CGRect(x: 0, y: 0, width: graphInfoView.frame.size.width, height: graphInfoView.frame.height)
                blurView.alpha = 0
                closeInfoViewButton.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { [self] _ in
                GIBottomAnchor.constant = 100
                self.view.layoutIfNeeded()
                blurView.frame = CGRect(x: 0, y: (graphInfoView.frame.size.height/4)*3, width: graphInfoView.frame.size.width, height: graphInfoView.frame.size.height/4)
                blurView.alpha = 1
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20, execute: { [self] in
                UIView.transition(
                    from: graphInfoView,
                    to: containerView,
                    duration: 1.0,
                    options: [.transitionFlipFromLeft, .showHideTransitionViews, .curveEaseInOut],
                    completion: { _ in
                        self.isGraphInfoViewShowing.toggle()
                    }
                )
            })
        } else {
            closeInfoViewButton.alpha = 1
            closeInfoViewButton.isEnabled = true
            graphInfoView.alpha = 1
            UIView.transition(
                from: containerView,
                to: graphInfoView,
                duration: 1.0,
                options: [.transitionFlipFromRight,/*.transitionFlipFromLeft,*/ .showHideTransitionViews, .curveEaseInOut],
                completion: { _ in
                    self.isGraphInfoViewShowing.toggle()
                }
            )
            
            //Not sur from here
            blurView.frame = CGRect(x: 0, y: 0, width: graphInfoView.frame.size.width, height: graphInfoView.frame.height)
            GIBottomAnchor.constant = containerView.frame.size.height - 100
            blurView.alpha = 0
            self.view.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: { [self] in
                GIBottomAnchor.constant = 100
                UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseInOut, animations: { [self] in
                    blurView.alpha = 1
                    self.view.layoutIfNeeded()
                    blurView.frame = CGRect(x: 0, y: (graphInfoView.frame.size.height/4)*3, width: graphInfoView.frame.size.width, height: graphInfoView.frame.size.height/4)
                })
            })
            //To here...
        }
    }
    
    
    @objc func didTapContentViewInfoButtonFoldAnim() {
        if isGraphInfoViewShowing {
            closeInfoViewButton.isEnabled = false
            GIBottomAnchor.constant = 200
            UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseIn, animations: { [self] in
                blurView.frame = CGRect(x: 0, y: 0, width: graphInfoView.frame.size.width, height: graphInfoView.frame.height/4)
                blurView.alpha = 0
                closeInfoViewButton.alpha = 0
                self.view.layoutIfNeeded()
//                containerBottomAnchor.constant = containerView.frame.size.height
            }, completion: { [self] _ in
                containerBottomAnchor.constant = 0
                UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseInOut, animations: {
                    containerView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: { [self] _ in
                    GIBottomAnchor.constant = 100
                    self.view.layoutIfNeeded()
                    blurView.frame = CGRect(x: 0, y: (graphInfoView.frame.size.height/4)*3, width: graphInfoView.frame.size.width, height: graphInfoView.frame.size.height/4)
                })
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
                UIView.transition(
                    from: graphInfoView,
                    to: containerView,
                    duration: 1.0,
                    options: [.transitionCrossDissolve, .showHideTransitionViews],
                    completion: { _ in
                        self.isGraphInfoViewShowing.toggle()
                    }
                )
            })
        } else {
            graphInfoView.alpha = 0
            closeInfoViewButton.isEnabled = true
            containerBottomAnchor.constant = containerView.frame.height
            blurView.frame = CGRect(x: 0, y: 0, width: graphInfoView.frame.size.width, height: graphInfoView.frame.height)
            UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseIn, animations: { [self] in
                containerView.alpha = 0
                self.view.layoutIfNeeded()
//                GIBottomAnchor.constant = containerView.frame.size.height
            }, completion: { [self] _ in
                GIBottomAnchor.constant = 100
                UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseInOut, animations: {
                    graphInfoView.alpha = 1
                    closeInfoViewButton.alpha = 1
                    blurView.frame = CGRect(x: 0, y: (graphInfoView.frame.size.height/4)*3, width: graphInfoView.frame.size.width, height: graphInfoView.frame.size.height/4)
                    self.view.layoutIfNeeded()
                }, completion: { [self] _ in
                    
                })
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
                UIView.transition(
                    from: containerView,
                    to: graphInfoView,
                    duration: 1.0,
                    options: [.transitionCrossDissolve, .showHideTransitionViews],
                    completion: { _ in
                        self.isGraphInfoViewShowing.toggle()
                    }
                )
            })
        }
    }
    
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        updateGIViewBeforeAppear()
//        didTapContentViewInfoButton()
        didTapContentViewInfoButton()
    }
    
    @objc func customStartButton(_ notification: Notification) {
        if startButtonsStackView.arrangedSubviews.count < 2 {
            UIView.animate(withDuration: 0.3, animations: { [self] in
                startButtonsStackView.alpha = 0
            }, completion: { [self] _ in
                startButtonsStackView.addArrangedSubview(customStartButton)
                updateStartButtonsStack(isCustom: true)
                setUpSahdows()
                startButton.titleLabel?.numberOfLines = 2
                UIView.animate(withDuration: 0.5, animations: { [self] in
                    startButtonsStackView.alpha = 1
                })
            })
        }
    }
    
    //Animated background view
    /*
    func initObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(noti:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationwillResignActive(noti:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground(noti: Notification) {
        BGColorTimer.invalidate()
    }
    
    @objc func applicationWillEnterForeground(noti: Notification) {
        animateEndBG()
    }
    
    @objc func applicationwillResignActive(noti: Notification) {
        BGColorTimer.invalidate()
    }
    
    func animateEndBG() {
        let newPointX = CGFloat.random(in: -5...0.5)
        let newPointY = CGFloat.random(in: -5...0.5)
        var px: CGFloat = 0
        var py: CGFloat = 0
        self.BGColorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (t) in
            px += (newPointX/50)
            py += (newPointY/50)
            self.BGAnimatedColored.start = CGPoint(x: CGFloat(px), y: CGFloat(py))
            if px >= newPointX && py >= newPointY {
                t.invalidate()
                self.animateEndBG()
            }
        }
    }*/
    
    //MARK: -Setup Shadows
    
    func setUpSahdows() {
        if traitCollection.userInterfaceStyle == .light {
            customModelButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: customModelButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
            tagModelButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: tagModelButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
            startButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
            customStartButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: customStartButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
            
            customModelButton.backgroundColor = UIColor(hexString: "#EBEBEB").withAlphaComponent(0.8)
            tagModelButton.backgroundColor = UIColor(hexString: "#EBEBEB").withAlphaComponent(0.8)
            startButton.backgroundColor = UIColor(hexString: "#EBEBEB").withAlphaComponent(0.8)
            customStartButton.backgroundColor = UIColor(hexString: "#EBEBEB").withAlphaComponent(0.8)
        } else {
            startButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
            customStartButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
            customModelButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
            tagModelButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
            
            customModelButton.backgroundColor = UIColor.clear
            tagModelButton.backgroundColor = UIColor.clear
            startButton.backgroundColor = UIColor.clear
            customStartButton.backgroundColor = UIColor.clear
        }
        startButton.titleLabel?.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
        customStartButton.titleLabel?.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
        customModelButton.titleLabel?.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
        tagModelButton.titleLabel?.textColor = traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor
        
        containerView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#E3E3E4").withAlphaComponent(0.4) : .black.withAlphaComponent(0.05)
//        containerView.dropShadow(traitCollection.userInterfaceStyle == .light ? LanguagesList.darkColor : LanguagesList.lightColor, opacity: 0.3, width: 0, height: 5, radius: 10, cornerR: containerView.layer.cornerRadius)
    }
    
//    let BGAnimatedColored: AnimatedColoredBackground = {
//        let view = AnimatedColoredBackground()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    //MARK: -Init Interactables
    
    let closeInfoViewButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton

        button.setImage(UIImage(systemName: "xmark.circle")!.tinted(with: UIColor.systemGray), for: .normal)
        button.addTarget(self, action: #selector(didTapContentViewInfoButton), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        return button
    }()
    
    let startButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 20
        stack.contentMode = .scaleToFill
        stack.isOpaque = false
        stack.isBaselineRelativeArrangement = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        let attributedText = NSMutableAttributedString(string: "Start", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 20) as Any])
        let customAttibutedText = NSAttributedString(string: "\nfull Library", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 12) as Any])
        
        let finalText = NSMutableAttributedString()
        
        finalText.append(attributedText)
        finalText.append(customAttibutedText)
        
        button.setAttributedTitle(finalText, for: .normal)
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(startTraining), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
//        button.backgroundColor = UIColor(named: "BackGroundColor")
        button.titleLabel?.textColor = .black
        return button
    }()
    
    let customStartButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        let attributedText = NSMutableAttributedString(string: "Start", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 20) as Any])
        let customAttibutedText = NSAttributedString(string: "\nwith custom content", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 12) as Any])
        
        let finalText = NSMutableAttributedString()
        
        finalText.append(attributedText)
        finalText.append(customAttibutedText)
        
        button.setAttributedTitle(finalText, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(startCustomTraining), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
//        button.backgroundColor = UIColor(named: "BackGroundColor")
        button.titleLabel?.textColor = .black
        return button
    }()
    
    let customModelButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        let attributedText = NSMutableAttributedString(string: "Manual selection", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 17) as Any])
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(customModel), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
//        button.backgroundColor = UIColor(named: "BackGroundColor")
        button.titleLabel?.textColor = .black
        return button
    }()
    
    let tagModelButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        let attributedText = NSMutableAttributedString(string: "Use tags", attributes: [NSAttributedString.Key.font: UIFont(name: "Comfortaa", size: 17) as Any])
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(tagModel), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
//        button.backgroundColor = UIColor(named: "BackGroundColor")
        button.titleLabel?.textColor = .black
        return button
    }()
    
    let progressView: ProgressBar = {
        let timerView = ProgressBar()
        timerView.translatesAutoresizingMaskIntoConstraints = false
        return timerView
    }()
    
    //MARK: -Custom Models & Tags
    
    @objc func customModel() {
        if traitCollection.userInterfaceStyle == .light {
            customModelButton.dropShadow(LanguagesList.darkColor, opacity: 0.1, width: 0, height: 0, radius: 5, cR: customModelButton.layer.cornerRadius, borderColor: LanguagesList.lightColor.withAlphaComponent(0.5))
        } else {
            customModelButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.2), shadowOpacity: 0.1, radius: 3, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.5))
        }
        performSegue(withIdentifier: "toCustomModelSelector", sender: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
            if traitCollection.userInterfaceStyle == .light {
                customModelButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: customModelButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
            } else {
                customModelButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
            }
        })
    }
    
    @objc func tagModel() {
        if traitCollection.userInterfaceStyle == .light {
            tagModelButton.dropShadow(LanguagesList.darkColor, opacity: 0.1, width: 0, height: 0, radius: 5, cR: tagModelButton.layer.cornerRadius, borderColor: LanguagesList.lightColor.withAlphaComponent(0.5))
        } else {
            tagModelButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.2), shadowOpacity: 0.1, radius: 3, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.5))
        }
        performSegue(withIdentifier: "toTagsModelSelector", sender: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [self] in
            if traitCollection.userInterfaceStyle == .light {
                tagModelButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: tagModelButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
            } else {
                tagModelButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
            }
        })
    }
    
    //MARK: -Starts
    
    @objc func startTraining() {
        if models.count < 2 {
            let alert = UIAlertController(title: "Quiz unvalable", message: "You must have at least 2 items in your library.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let addWords = UIAlertAction(title: "Add words", style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.tabBarController?.selectedIndex = 1
                    self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "showMiracleToAddWords"), object: nil)
                }
            })
            
            alert.addAction(cancel)
            alert.addAction(addWords)
            
            present(alert, animated: true)
        } else {
            guard let vc = storyboard?.instantiateViewController(identifier: "WalkthroughViewController") as? QuizViewController else {
                return
            }
            vc.modalPresentationStyle = .fullScreen
            if traitCollection.userInterfaceStyle == .light {
                startButton.dropShadow(LanguagesList.darkColor, opacity: 0.1, width: 0, height: 0, radius: 5, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.lightColor.withAlphaComponent(0.5))
            } else {
    //            startButton.addInnerShadow(shadowColor: lightColor.withAlphaComponent(0.2), shadowOpacity: 0.1, radius: 3, borderWidth: 1.5, borderColor: darkColor.withAlphaComponent(0.5))
                startButton.dropShadow(LanguagesList.lightColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.darkColor)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: { [self] in
                getAllItems()
                
//                LanguagesList.shuffledModel = []
//                let uds = UserDefaults.standard.object(forKey: "isCustomContent") as? Bool
//                if uds != nil && uds == true {
//                    print("custom content")
//                    LanguagesList.shuffledModel = LanguagesList.customContentList.shuffled()
//                } else {
//                    print("default")
//                    LanguagesList.shuffledModel = models.shuffled()
//                }
                LanguagesList.shuffledModel = models.shuffled()
                moveContentView(toindex: LanguagesList.statWordsList.count-1)
                if isGraphInfoViewShowing {
                    didTapContentViewInfoButton()
                }
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: { [self] in
                    superContainerView.transform = CGAffineTransform(scaleX: 0, y: 0)
                })
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                self.present(vc, animated: true, completion: {
                    if traitCollection.userInterfaceStyle == .light {
                        self.startButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
                    } else {
                        startButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
                    }
//                    customStartButton.removeFromSuperview()
//                    startButtonsStackView.removeFromSuperview()
//                    updateStartButtonsStack(isCustom: false)
                })
            })
        }
    }
    
    @objc func startCustomTraining() {
        guard let vc = storyboard?.instantiateViewController(identifier: "WalkthroughViewController") as? QuizViewController else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        if traitCollection.userInterfaceStyle == .light {
            customStartButton.dropShadow(LanguagesList.darkColor, opacity: 0.1, width: 0, height: 0, radius: 5, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.lightColor.withAlphaComponent(0.5))
        } else {
            customStartButton.dropShadow(LanguagesList.lightColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.darkColor)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: { [self] in
            getAllItems()
            
            LanguagesList.shuffledModel = LanguagesList.customContentList.shuffled()
            moveContentView(toindex: LanguagesList.statWordsList.count-1)
            if isGraphInfoViewShowing {
                didTapContentViewInfoButton()
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: { [self] in
                superContainerView.transform = CGAffineTransform(scaleX: 0, y: 0)
            })
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            self.present(vc, animated: true, completion: {
                if traitCollection.userInterfaceStyle == .light {
                    self.customStartButton.dropShadow(LanguagesList.darkColor, opacity: 0.3, width: 5, height: 5, radius: 10, cR: startButton.layer.cornerRadius, borderColor: LanguagesList.lightColor)
                } else {
                    customStartButton.addInnerShadow(shadowColor: LanguagesList.lightColor.withAlphaComponent(0.7), shadowOpacity: 0.2, radius: 6, borderWidth: 1.5, borderColor: LanguagesList.darkColor.withAlphaComponent(0.9))
                }
//                customStartButton.removeFromSuperview()
//                startButtonsStackView.removeFromSuperview()
//                updateStartButtonsStack(isCustom: false)
            })
        })
    }
    
    func moveContentView(toindex: Int) {
        if (walkthroughPageViewController?.currentIndex) != nil {
            walkthroughPageViewController?.avancerPage(toindex: toindex)
        }
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let uds = UserDefaults.standard.object(forKey: "isCustomContent") as? Bool
        if uds != nil && uds == true {
            customModelButton.backgroundColor = .systemGreen
        } else {
            customModelButton.backgroundColor = .white
        }
    }*/
    
    func getAllItems() {
        do {
            let request = LangData.fetchRequest() as NSFetchRequest<LangData>
            
            let sort = NSSortDescriptor(key: "languages", ascending: true)
            request.sortDescriptors = [sort]
            
            models = try context.fetch(request)
        } catch {
            print("ERROR: Enable to get items")
        }
    }

    func setUpLayout() {
    
        updateStartButtonsStack(isCustom: false)
        
        customModelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        customModelButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        customModelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -350).isActive = true
        customModelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tagModelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tagModelButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        tagModelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -250).isActive = true
        tagModelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
//        progressView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
//        progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
//        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
//        progressView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        
//        BGAnimatedColored.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//        BGAnimatedColored.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
//        BGAnimatedColored.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
//        BGAnimatedColored.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        closeInfoViewButton.topAnchor.constraint(equalTo: graphInfoView.topAnchor, constant: 15).isActive = true
        closeInfoViewButton.trailingAnchor.constraint(equalTo: graphInfoView.trailingAnchor, constant: -15).isActive = true
        closeInfoViewButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeInfoViewButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func updateStartButtonsStack(isCustom: Bool) {
        view.addSubview(startButtonsStackView)
        
        startButtonsStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        startButtonsStackView.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20).isActive = isCustom
        startButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = isCustom
        
        startButtonsStackView.widthAnchor.constraint(equalToConstant: 200).isActive = !isCustom
        startButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = !isCustom
        
        startButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? MainViewPageController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    func updateUI() {
        if let index = walkthroughPageViewController?.currentIndex {
//            print(index)
            switch index {
            case 0...LanguagesList.statWordsList.count-1:
                print("walked")
            case LanguagesList.statWordsList.count:
                print("last")
            default:
                break
            }
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    //MARK: -Graph Info View
    
    let GITitleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Info view"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let GIdescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This view represents..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = .zero
        label.textColor = .systemGray
        return label
    }()
    
    var blur = UIBlurEffect()
    var blurView = UIVisualEffectView()
    
    func initInfoView() {
        graphInfoView.addSubview(closeInfoViewButton)
        graphInfoView.addSubview(GITitleView)
        graphInfoView.addSubview(GIdescriptionLabel)
        
        graphInfoView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#DDE1F0", alpha: 1) : UIColor(hexString: "#08133B").withAlphaComponent(0.3)
        if !isGraphInfoViewShowing {
            closeInfoViewButton.alpha = 0
            closeInfoViewButton.isEnabled = false
            graphInfoView.alpha = 0
        }
        
        blur = UIBlurEffect(style: traitCollection.userInterfaceStyle == .light ? .systemUltraThinMaterialLight : .systemChromeMaterialDark)
        blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = (traitCollection.userInterfaceStyle == .light ? 0.5 : 1)
        blurView.frame = CGRect(x: 0, y: (graphInfoView.frame.size.height/4)*3, width: graphInfoView.frame.size.width, height: graphInfoView.frame.size.height/4)
        blurView.roundCorners([.bottomLeft, .bottomRight], radius: 40)
        graphInfoView.addSubview(blurView)

        setupGIsubs()
    }
    
    func updateGIViewBeforeAppear() {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...LanguagesList.statWordsList.count:
                GITitleView.text = "Info on stats view n°\(walkthroughPageViewController!.currentIndex+1)"
                GIdescriptionLabel.text = """
                                        Lorem ipsum, dolor sit amet consectetur adipisicing elit. Consequatur tempore sunt et asperiores quidem magnam laborum optio, reprehenderit cupiditate corporis. Fugit libero velit optio eaque error. Repellendus magni suscipit quo ipsum perspiciatis id! Possimus optio excepturi rem corporis nobis tenetur, alias expedita.
                                        """
            default:
                break
            }
        }
        graphInfoView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#DDE1F0", alpha: 1) : UIColor(hexString: "#08133B").withAlphaComponent(0.3)
        blur = UIBlurEffect(style: traitCollection.userInterfaceStyle == .light ? .systemUltraThinMaterialLight : .systemChromeMaterialDark)
        blurView.alpha = (traitCollection.userInterfaceStyle == .light ? 0.5 : 1)
        self.view.updateFocusIfNeeded()
    }
    
    func setupGIsubs() {
        GITitleView.topAnchor.constraint(equalTo: graphInfoView.topAnchor, constant: 10).isActive = true
        GITitleView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        GITitleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        GIdescriptionLabel.topAnchor.constraint(equalTo: graphInfoView.topAnchor, constant: 45).isActive = true
        GIdescriptionLabel.leadingAnchor.constraint(equalTo: graphInfoView.leadingAnchor, constant: 15).isActive = true
        GIdescriptionLabel.trailingAnchor.constraint(equalTo: graphInfoView.trailingAnchor, constant: -15).isActive = true
        GIdescriptionLabel.bottomAnchor.constraint(equalTo: graphInfoView.bottomAnchor, constant: -(graphInfoView.frame.size.height/4)-5).isActive = true
    }
}
