//
//  QuizViewController.swift
//  Voc+
//
//  Created by Maxence Gama on 02/03/2021.
//
import UIKit
import CoreData
import Lottie

class QuizViewController: UIViewController, WalkthroughPageViewControllerDelegate {

    var walkthroughPageViewController: WalkthroughPageViewController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    private var models = [LangData]()
    
    @IBOutlet var containerView: UIView!
    
    let color: UIColor = UIColor(hexString: "#d0e8f2")
    let nightColor: UIColor = UIColor(hexString: "#0A5D80")
    let darkColor: UIColor = UIColor(hexString: "#456268")
    let lightColor: UIColor = UIColor(hexString: "#EBEBEB")
    let containerBorderRadius: CGFloat = 80
    
    var animationView: AnimationView?
    var animationView2: AnimationView?
//    var BGanimationView: AnimationView?
    
    var isReversed: Bool = false
    
    var BGColorTimer = Timer()
    
    public var indexNum: Int = 1 {
        didSet {
            updateCounter(index: indexNum)
        }
    }
    
    func updateCounter(index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (index != 1 ? 2 : 0), execute: {
            UILabel.animate(withDuration: 1, animations: { [self] in
                if index <= LanguagesList.shuffledModel.count {
                    counter.text = "\(index)/\(LanguagesList.shuffledModel.count)"
                }
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        BGanimationView = .init(name: "blurred_colored_bg_animated")
//        BGanimationView!.translatesAutoresizingMaskIntoConstraints = false
//        BGanimationView!.contentMode = .scaleAspectFit
//        BGanimationView!.loopMode = .loop
//        BGanimationView!.animationSpeed = 0.5
//        BGanimationView!.backgroundBehavior = .pauseAndRestore
//        BGanimationView!.frame = view.bounds
//        BGanimationView!.alpha = 0.5
//
//        let blur = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.frame = view.bounds
//
//        view.insertSubview(blurView, belowSubview: containerView)
//        view.insertSubview(BGanimationView!, belowSubview: blurView)
//        view.backgroundColor = .white
        
        LanguagesList.errorsTextList = []
        LanguagesList.errorsList = []
        LanguagesList.totalLetters = 0
        LanguagesList.wrongLetters = 0
        
        view.addSubview(stopTrainingButton)
        view.addSubview(answerTextField)
        view.addSubview(sendAnswerButton)
        view.addSubview(animationContainer)
        view.addSubview(animationContainer2)
        view.addSubview(counterView)
        counterView.addSubview(counter)
        
        animationView = .init(name: "23222-checkmark")
        animationView!.translatesAutoresizingMaskIntoConstraints = false
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 2
        animationView!.backgroundBehavior = .pauseAndRestore
        animationView!.frame = animationContainer.bounds
        
        animationContainer.addSubview(animationView!)
        animationContainer.alpha = 0
        
        animationView2 = .init(name: "wrong-answer")
        animationView2!.translatesAutoresizingMaskIntoConstraints = false
        animationView2!.contentMode = .scaleAspectFit
        animationView2!.loopMode = .playOnce
        animationView2!.animationSpeed = 2
        animationView2!.backgroundBehavior = .pauseAndRestore
        animationView2!.frame = animationContainer.bounds
        
        animationContainer2.addSubview(animationView2!)
        animationContainer2.alpha = 0
        
//        BGanimationView!.play()
        
//        view.backgroundColor = .clear
        view.insertSubview(BGAnimatedColored, belowSubview: containerView)
        
        animateStartBG()
        animateEndBG()
        
        setUpLayout()
        
        answerTextField.becomeFirstResponder()
        
        initShadowsAndColors()
        
        updateCounter(index: indexNum)
        
        initObservers()
        
        addBlur(stopTrainingButton)
//        stopTrainingButton.backgroundColor = .clear
        addBlur(counterView)
//        counterView.backgroundColor = .clear
        addBlur(answerTextField)
//        answerTextField.backgroundColor = .clear
        
        getAllItems()
    }
    
    func initObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(noti:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(noti:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationwillResignActive(noti:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground(noti: Notification) {
        BGColorTimer.invalidate()
    }
    
    @objc func applicationWillEnterForeground(noti: Notification) {
        animateStartBG()
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
    }
    
    func animateStartBG() {
        /*
        let newPointX = CGFloat.random(in: 0...2)
        let newPointY = CGFloat.random(in: 0...2)
        var px: CGFloat = 0
        var py: CGFloat = 0
        self.BGColorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (t) in
            px += (newPointX/50)
            py += (newPointY/50)
            self.BGAnimatedColored.end = CGPoint(x: CGFloat(px), y: CGFloat(py))
            if px >= newPointX && py >= newPointY {
                t.invalidate()
                self.animateStartBG()
            }
        }
        */
    }
    
    func initShadowsAndColors() {
        
//        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? color : nightColor
        
        containerView.backgroundColor = .clear
        
//        containerView.dropShadow(traitCollection.userInterfaceStyle == .light ? darkColor : lightColor , opacity: 0.3, width: 0, height: 5, radius: 10, cornerR: CGFloat(containerBorderRadius))
        containerView.layer.cornerRadius = containerBorderRadius
        containerView.addInnerShadowToView(shadowColor: traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, shadowOpacity: 1, radius: 5, borderWidth: 2, borderColor: traitCollection.userInterfaceStyle == .light ? darkColor.withAlphaComponent(0.5) : lightColor.withAlphaComponent(0.5))
         containerView.backgroundColor = view.backgroundColor?.withAlphaComponent(0.1)
        
        counterView.dropShadow(traitCollection.userInterfaceStyle == .light ? darkColor : .black, opacity: 0.3, width: 1, height: 2, radius: 5, cornerR: 15)
        counterView.layer.cornerRadius = 15
        counterView.backgroundColor = view.backgroundColor?.withAlphaComponent(0.2)
        counter.dropShadow(opacity: 0.5, radius: 5)
        counter.textColor = traitCollection.userInterfaceStyle == .light ? darkColor : lightColor
        
        stopTrainingButton.dropShadow(traitCollection.userInterfaceStyle == .light ? darkColor : .black, opacity: 0.3, width: 1, height: 2, radius: 5, cR: 15, borderColor: UIColor.clear)
        stopTrainingButton.backgroundColor = view.backgroundColor?.withAlphaComponent(0.2)
        stopTrainingButton.setTitleColor(traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, for: .normal)
        
        answerTextField.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#fcf8ec").withAlphaComponent(0.3) : UIColor(hexString: "#302F2D").withAlphaComponent(0.3)
        
        sendAnswerButton.backgroundColor = UIColor.clear
        sendAnswerButton.addInnerShadow(shadowColor: traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, shadowOpacity: 1, radius: 5, borderWidth: 2, borderColor: traitCollection.userInterfaceStyle == .light ? darkColor.withAlphaComponent(0.5) : lightColor.withAlphaComponent(0.5))
        sendAnswerButton.setTitleColor(traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, for: .normal)
    }
    
    func addBlur(_ target: AnyObject) {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = target.bounds
        blurView.layer.cornerRadius = target.layer!.cornerRadius
        
        target.addSubview(blurView)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(traitCollection)
        initShadowsAndColors()
    }
    
    let BGAnimatedColored: AnimatedColoredBackground = {
        let view = AnimatedColoredBackground()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let animationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let animationContainer2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var stopTrainingButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Arrêter".localized(), for: .normal)
        button.addTarget(self, action: #selector(stopTraining), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        return button
    }()
    
    var answerTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your answer"
        field.adjustsFontSizeToFitWidth = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        field.clearsOnBeginEditing = true
        field.clearButtonMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var sendAnswerButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.label, for: .normal)
        button.setTitle("OK", for: .normal)
        button.addTarget(self, action: #selector(testAnswer), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    let counter: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.contentMode = .center
        label.textColor = .label
//        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let counterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func stopTraining() {
        UIView.animate(withDuration: 0.3, animations: { [self] in
            answerTextField.alpha = 0
            sendAnswerButton.alpha = 0
            answerTextField.resignFirstResponder()
            containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
            stopTrainingButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            counterView.transform = CGAffineTransform(scaleX: 0, y: 0)
        })
        let alert = UIAlertController(title: "Stop quiz ?", message: "You are about to cancel your current quiz. Your datas won't be saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
            UIView.animate(withDuration: 0.3, animations: { [self] in
                self!.answerTextField.alpha = 1
                self!.sendAnswerButton.alpha = 1
                self!.answerTextField.becomeFirstResponder()
                self!.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self!.stopTrainingButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                self!.counterView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            self!.close()
        }))
        
        present(alert, animated: true)
    }
    
    func close() {
//        UserDefaults.standard.setValue(false, forKey: "isCustomContent")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func testAnswer() {
        print(answerTextField.text!)
        if let index = walkthroughPageViewController?.currentIndex {
            checkAnswerForValidating(answer: answerTextField.text!, index: index)
        }
        answerTextField.text = ""
        updateUI()
    }
    
    func checkAnswerForValidating(answer: String, index: Int) {
        var langToTest = !isReversed ? LanguagesList.shuffledModel[index].language2! : LanguagesList.shuffledModel[index].language1!
        
        var newAnswer = answer
        if answer.last == " " {
            newAnswer.removeLast()
            print("space remove: \(newAnswer)")
        }
        
        if langToTest.last == " " {
            langToTest.removeLast()
            print("space remove: \(langToTest)")
        }
        
        if newAnswer.lowercased() != langToTest.lowercased() {
            print("wrong answer,\nexpected: \(langToTest)")
            LanguagesList.errorsList.append(index)
            LanguagesList.errorsTextList.append(answer)
            sendAnswerButton.isEnabled = false
            moveToNextIfNotCorrect()
            playAnimTransitionIfWrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            })
            
            for i in models {
                if i.language1!.contains(langToTest) || i.language2!.contains(langToTest){
                    i.numOfWrongAnswer += 1
//                    print(i)
                }
            }
            
            for i in 0..<(langToTest.count > newAnswer.count ? newAnswer.count : langToTest.count) {
                if String(newAnswer[i].lowercased()) != String(langToTest[i].lowercased()) {
                    LanguagesList.wrongLetters += 1
//                    print("\(LanguagesList.wrongLetters)")
                }
            }
            if langToTest.count > newAnswer.count {
                LanguagesList.wrongLetters += langToTest.count-newAnswer.count
            } else if langToTest.count > newAnswer.count {
                LanguagesList.wrongLetters += newAnswer.count-langToTest.count
            }
            
            LanguagesList.totalLetters += (langToTest.count > newAnswer.count ? langToTest.count : newAnswer.count)
            
        } else {
            print("good")
            sendAnswerButton.isEnabled = false
            moveToNextIfCorrect()
            playAnimTransitionIfCorrect()
            LanguagesList.totalLetters += langToTest.count
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            })
        }
    }
    
    func moveToNextIfCorrect() {
        if let index = walkthroughPageViewController?.currentIndex {
            if LanguagesList.shuffledModel.count > 1 {
                switch index {
                case 0...LanguagesList.shuffledModel.count-2:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7, execute: { [self] in
                        animationContainer.alpha = 0
                        UIView.animate(withDuration: 0.3, animations: {
                            self.containerView.alpha = 1
                            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            let ramdom = Bool.random()
                            walkthroughPageViewController?.avancerPage(isreversed: ramdom)
                            isReversed = ramdom
                            sendAnswerButton.isEnabled = true
                        })
                    })
                case LanguagesList.shuffledModel.count-1:
                    self.stopTrainingButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.counterView.transform = CGAffineTransform(scaleX: 0, y: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7, execute: { [self] in
                        animationContainer.alpha = 0
                        answerTextField.resignFirstResponder()
                        moveToresult()
                    })
                default:
                    break
                }
            } else {
                self.stopTrainingButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.counterView.transform = CGAffineTransform(scaleX: 0, y: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                    animationContainer2.alpha = 0
                    answerTextField.resignFirstResponder()
                    moveToresult()
                })
            }
        }
    }
    
    func moveToNextIfNotCorrect() {
        if let index = walkthroughPageViewController?.currentIndex {
            if LanguagesList.shuffledModel.count > 1 {
                switch index {
                case 0...LanguagesList.shuffledModel.count-2:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                        animationContainer2.alpha = 0
                        UIView.animate(withDuration: 0.3, animations: {
                            self.containerView.alpha = 1
                            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            let ramdom = Bool.random()
                            walkthroughPageViewController?.avancerPage(isreversed: ramdom)
                            isReversed = ramdom
                            sendAnswerButton.isEnabled = true
                        })
                    })
                case LanguagesList.shuffledModel.count-1:
                    self.stopTrainingButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.counterView.transform = CGAffineTransform(scaleX: 0, y: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                        animationContainer2.alpha = 0
                        answerTextField.resignFirstResponder()
                        moveToresult()
                    })
                default:
                    break
                }
            } else {
                self.stopTrainingButton.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.counterView.transform = CGAffineTransform(scaleX: 0, y: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                    animationContainer2.alpha = 0
                    answerTextField.resignFirstResponder()
                    moveToresult()
                })
            }
        }
    }
    
    func moveToresult() {
        UIView.animate(withDuration: 0.3, animations: { [self] in
            answerTextField.alpha = 0
            sendAnswerButton.alpha = 0
            answerTextField.resignFirstResponder()
            containerView.transform = CGAffineTransform(scaleX: 0, y: 0)
            stopTrainingButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            counterView.transform = CGAffineTransform(scaleX: 0, y: 0)
        })
        
        let slide = ResultsViewController()
        slide.modalPresentationStyle = .custom
        slide.transitioningDelegate = self
        self.present(slide, animated: true, completion: nil)
//        performSegue(withIdentifier: "toResults", sender: self)
    }
    
    func playAnimTransitionIfCorrect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.005, y: 0.005)
        }, completion: { [self] _ in
            animationContainer.alpha = 1
            animationView!.play()
        })
    }
    
    func playAnimTransitionIfWrong() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.005, y: 0.005)
        }, completion: { [self] _ in
            animationContainer2.alpha = 1
            animationView2!.play()
        })
    }

    func setUpLayout() {
        stopTrainingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stopTrainingButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        stopTrainingButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        stopTrainingButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        answerTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -350).isActive = true
        answerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        answerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        answerTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        sendAnswerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -350).isActive = true
        sendAnswerButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45).isActive = true
        sendAnswerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        sendAnswerButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        animationContainer.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        animationContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        animationContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        animationContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        animationView?.topAnchor.constraint(equalTo: animationContainer.topAnchor).isActive = true
        animationView?.bottomAnchor.constraint(equalTo: animationContainer.bottomAnchor).isActive = true
        animationView?.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor).isActive = true
        animationView?.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor).isActive = true
        
        animationContainer2.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        animationContainer2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        animationContainer2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        animationContainer2.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        animationView2?.topAnchor.constraint(equalTo: animationContainer2.topAnchor).isActive = true
        animationView2?.bottomAnchor.constraint(equalTo: animationContainer2.bottomAnchor).isActive = true
        animationView2?.trailingAnchor.constraint(equalTo: animationContainer2.trailingAnchor).isActive = true
        animationView2?.leadingAnchor.constraint(equalTo: animationContainer2.leadingAnchor).isActive = true
        
        counterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        counterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        counterView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        counterView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        counter.topAnchor.constraint(equalTo: counterView.topAnchor).isActive = true
        counter.leadingAnchor.constraint(equalTo: counterView.leadingAnchor).isActive = true
        counter.trailingAnchor.constraint(equalTo: counterView.trailingAnchor).isActive = true
        counter.bottomAnchor.constraint(equalTo: counterView.bottomAnchor).isActive = true
        
//        BGanimationView!.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        BGanimationView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        BGanimationView!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        BGanimationView!.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        BGAnimatedColored.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        BGAnimatedColored.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        BGAnimatedColored.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        BGAnimatedColored.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func updateUI() {
        if let index = walkthroughPageViewController?.currentIndex {
            print(index)
            switch index {
            case 0...LanguagesList.shuffledModel.count-1:
                print("walked")
            case LanguagesList.shuffledModel.count:
                print("last")
            default:
                break
            }
            indexNum = index+2
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
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
}

extension QuizViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        ResultPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
