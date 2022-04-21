//
//  QuizView.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 19/04/2021.
//







//Backup of QuizViewController
///Old version of the view
///If needed to put back default view background
///Copy-&-Paste




/*
import UIKit
import CoreData
import Lottie

class QuizViewController: UIViewController, WalkthroughPageViewControllerDelegate {

    var walkthroughPageViewController: WalkthroughPageViewController?
    
    @IBOutlet var containerView: UIView!
    
    let color: UIColor = UIColor(hexString: "#d0e8f2")
    let nightColor: UIColor = UIColor(hexString: "#0A5D80")
    let darkColor: UIColor = UIColor(hexString: "#456268")
    let lightColor: UIColor = UIColor(hexString: "#EBEBEB")
    let containerBorderRadius = 80
    
    var animationView: AnimationView?
    var animationView2: AnimationView?
    
    var isReversed: Bool = false
    
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
        
        LanguagesList.errorsTextList = []
        LanguagesList.errorsList = []
        
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
        
        setUpLayout()
        
        answerTextField.becomeFirstResponder()
        
        initShadowsAndColors()
        
        updateCounter(index: indexNum)
    }
    
    func initShadowsAndColors() {
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? color : nightColor
        
        containerView.dropShadow(traitCollection.userInterfaceStyle == .light ? darkColor : .black, opacity: 0.4, width: 0, height: 5, radius: 10, cornerR: CGFloat(containerBorderRadius))
        containerView.backgroundColor = traitCollection.userInterfaceStyle == .light ? color : nightColor
        containerView.layer.cornerRadius = CGFloat(containerBorderRadius)
        
        counterView.dropShadow(traitCollection.userInterfaceStyle == .light ? darkColor : .black, opacity: 0.3, width: 1, height: 2, radius: 5, cornerR: 15)
        counterView.layer.cornerRadius = 15
        counterView.backgroundColor = view.backgroundColor
        
        stopTrainingButton.dropShadow(traitCollection.userInterfaceStyle == .light ? darkColor : .black, opacity: 0.3, width: 1, height: 2, radius: 5, cR: 15, borderColor: UIColor.clear)
        stopTrainingButton.backgroundColor = view.backgroundColor
        
        counter.dropShadow(opacity: 0.5, radius: 5)
        
        answerTextField.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#fcf8ec") : UIColor(hexString: "#302F2D")
        sendAnswerButton.backgroundColor = UIColor.clear
        sendAnswerButton.addInnerShadow(shadowColor: traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, shadowOpacity: 0.8, radius: 5, borderWidth: 1.5, borderColor: traitCollection.userInterfaceStyle == .light ? darkColor.withAlphaComponent(0.3) : lightColor.withAlphaComponent(0.2))
        sendAnswerButton.setTitleColor(traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, for: .normal)
        
        stopTrainingButton.setTitleColor(traitCollection.userInterfaceStyle == .light ? darkColor : lightColor, for: .normal)
        counter.textColor = traitCollection.userInterfaceStyle == .light ? darkColor : lightColor
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
        })
        let alert = UIAlertController(title: "Stop quiz ?", message: "You are about to cancel your current quiz.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { [weak self] _ in
            UIView.animate(withDuration: 0.2, animations: { [self] in
                self!.answerTextField.alpha = 1
                self!.sendAnswerButton.alpha = 1
            })
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self!.close()
        }))
        
        present(alert, animated: true)
    }
    
    func close() {
        UserDefaults.standard.setValue(false, forKey: "isCustomContent")
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
        let langToTest = !isReversed ? LanguagesList.shuffledModel[index].language2 : LanguagesList.shuffledModel[index].language1

        if answer.lowercased() != langToTest?.lowercased() {
            print("wrong answer,\nexpected: \(langToTest!)")
            LanguagesList.errorsList.append(index)
            LanguagesList.errorsTextList.append(answer)
            sendAnswerButton.isEnabled = false
            moveToNextIfNotCorrect()
            playAnimTransitionIfWrong()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            })
        } else {
            print("good")
            sendAnswerButton.isEnabled = false
            moveToNextIfCorrect()
            playAnimTransitionIfCorrect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            })
        }
    }
    
    func moveToNextIfCorrect() {
        if let index = walkthroughPageViewController?.currentIndex {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7, execute: { [self] in
                    animationContainer.alpha = 0
                    answerTextField.resignFirstResponder()
                    performSegue(withIdentifier: "toResults", sender: self)
                })
            default:
                break
            }
        }
    }
    
    func moveToNextIfNotCorrect() {
        if let index = walkthroughPageViewController?.currentIndex {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [self] in
                    animationContainer2.alpha = 0
                    answerTextField.resignFirstResponder()
                    performSegue(withIdentifier: "toResults", sender: self)
                })
            default:
                break
            }
        }
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
}


extension QuizViewController: DismissPreviousController {
    func dismissPrevious() {
        self.dismiss(animated: false, completion: nil)
    }
}
*/
