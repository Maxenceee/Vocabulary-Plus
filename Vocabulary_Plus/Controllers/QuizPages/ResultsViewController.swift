//
//  ResultsViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 03/04/2021.
//

import UIKit
import CoreData


class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var animTimer = Timer()
    var models = [Statistics]()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let progressView: ProgressInfo = {
        let timerView = ProgressInfo()
        timerView.translatesAutoresizingMaskIntoConstraints = false
        return timerView
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
        var image = UIImage(systemName: "xmark", withConfiguration: boldConfig)
        //image = image!.scalePreservingAspectRatio(targetSize: CGSize(width: button.frame.width/2, height: button.frame.height/2))
        
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hexString: "#818185")
//        button.backgroundColor = UIColor(hexString: "#D7D7D9")
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        button.contentVerticalAlignment = .center
        button.contentMode = .scaleToFill

        return button
    }()
    
    @objc func closeView() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        animTimer.invalidate()
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        getStatistics()
        updateDayStats()
        
//        UserDefaults.standard.setValue(false, forKey: "isCustomContent")
        
//        delegate.dismissPrevious()

        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#DDE1F0") : UIColor.black
        
//        view.addSubview(waitLabel)
        view.addSubview(countLabel)
        view.addSubview(closeButton)
        
        if LanguagesList.errorsList.count != 0 {
            view.addSubview(tableView)
//            view.addSubview(progressView)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.frame = self.view.frame
        }
        addBlur(closeButton)
        
        setUpLayout()
        
        if LanguagesList.errorsList.count != 0 {
            countLabel.text = "\(LanguagesList.shuffledModel.count-LanguagesList.errorsList.count)/\(LanguagesList.shuffledModel.count) good answer\(LanguagesList.errorsList.count < 2 ? "" : "s")"
        } else {
            countLabel.text = "You have no errors"
            countLabel.textColor = .black
            countLabel.textAlignment = .center
        }
        
        animTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (t) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [self] in
                waitLabel.frame.origin.y += 20
            }, completion: { succes in
                if succes {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [self] in
                        waitLabel.frame.origin.y -= 20
                    }, completion: { succes in
                        if succes {
                            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [self] in
                                waitLabel.frame.origin.y += 20
                            }, completion: { succes in
                                if succes {
                                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [self] in
                                        waitLabel.frame.origin.y -= 20
                                    })
                                }
                            })
                        }
                    })
                }
            })
        })
        
    }
    
    func updateDayStats() {
        models[0].total += Float(LanguagesList.shuffledModel.count)
        models[0].goodAnswers += Float(LanguagesList.shuffledModel.count-LanguagesList.errorsList.count)
        models[0].wrongAnswers += Float(LanguagesList.errorsList.count)
        models[0].lastTryTotal = Float(LanguagesList.shuffledModel.count)
        models[0].lastTryGoodAnswers = Float(LanguagesList.shuffledModel.count-LanguagesList.errorsList.count)
        models[0].totalLetters += Float(LanguagesList.totalLetters)
        models[0].wrongLetters += Float(LanguagesList.wrongLetters)
        print("day stats updated:\n\(models[0])")
        
        do {
            try context.save()
            getStatistics()
        } catch {
            print("ERROR: Enable to update stats")
        }
    }
    
    func addBlur(_ target: AnyObject) {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = target.bounds
        blurView.layer.cornerRadius = target.layer!.cornerRadius
        
        target.addSubview(blurView)
    }
    
    func setUpLayout() {
//        waitLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
//        waitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
//        waitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
//        waitLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        if LanguagesList.errorsList.count != 0 {
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
//            progressView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//            progressView.widthAnchor.constraint(equalToConstant: 100).isActive = true
//            progressView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
//            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            countLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        } else {
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
    
        countLabel.bottomAnchor.constraint(equalTo: LanguagesList.errorsList.count != 0 ? tableView.topAnchor : view.centerYAnchor, constant: -5).isActive = true
        countLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    let waitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Scroll down here to dismiss"
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LanguagesList.errorsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        let model = LanguagesList.shuffledModel[LanguagesList.errorsList[indexPath.row] as! Int]
        
        var myString: String!
        if LanguagesList.errorsTextList[indexPath.row] as! String == "" {
            myString = "Your answer : No answer"
        } else {
            myString = "Your answer : \(LanguagesList.errorsTextList[indexPath.row])"
        }
        
        var myMutableString = NSMutableAttributedString()
        var myMutableString2 = NSMutableAttributedString()
        var myMutableString3 = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(string: "Error at : \(model.language1!)\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed, range: NSRange(location: 0,length: 10))
        
        myMutableString2 = NSMutableAttributedString(string: "Expected : \(model.language2!)\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        myMutableString2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: 0,length: 10))
        
        myMutableString3 = NSMutableAttributedString(string: myString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        myMutableString3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemTeal, range: NSRange(location: 0,length: 13))

        let finalText = NSMutableAttributedString()
        
        finalText.append(myMutableString)
        finalText.append(myMutableString2)
        finalText.append(myMutableString3)
        
        cell.textLabel?.attributedText = finalText
        cell.textLabel?.numberOfLines = 0

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
     return 100
    }
    
    func getStatistics() {
        do {
            let request = Statistics.fetchRequest() as NSFetchRequest<Statistics>
            
            let sort = NSSortDescriptor(key: "day", ascending: false)
            request.sortDescriptors = [sort]
            
            models = try context.fetch(request)
            
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        var translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
//        guard translation.y >= -330 else { return }
        
        print(translation.y)
        
        if translation.y < 0 {
            translation.y -= translation.y/1.1
        }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 10, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 || translation.y > self.view.frame.size.height/2 {
                self.closeView()
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
