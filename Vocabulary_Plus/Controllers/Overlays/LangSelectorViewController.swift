//
//  LangSelectorViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 24/03/2021.
//

import UIKit
import Foundation

protocol SetItemLanguages {
    func SetItemL(langs: String, l1: Int, l2: Int)
}

class LangSelectorViewController: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var delegate: SetItemLanguages!
    
    @IBOutlet var sliderIndicator: UIView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var validateButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var row1: Int = 0
    var row2: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        sliderIndicator.roundCorners(.allCorners, radius: 10)
        
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
        validateButton.roundCorners(.allCorners, radius: 10)
        validateButton.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#3AB6FD") : UIColor(hexString: "#1C587A")
        cancelButton.roundCorners(.allCorners, radius: 10)
        cancelButton.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#3AB6FD") : UIColor(hexString: "#1C587A")
        
        validateButton.alpha = 0.5
        
        if LanguagesList.rowsList.count != 0 {
            pickerView.selectRow(LanguagesList.rowsList[0], inComponent: 0, animated: true)
            pickerView.selectRow(LanguagesList.rowsList[1], inComponent: 1, animated: true)
            row1 = LanguagesList.rowsList[0]
            row2 = LanguagesList.rowsList[1]
            
            validateButton.alpha = 1
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#F1F1F1") : UIColor(hexString: "#353535")
        sliderIndicator.backgroundColor = traitCollection.userInterfaceStyle == .light ? .black : .white
        validateButton.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#3AB6FD") : UIColor(hexString: "#1C587A")
        cancelButton.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor(hexString: "#3AB6FD") : UIColor(hexString: "#1C587A")
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
            if dragVelocity.y >= 1300 || translation.y > 150 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }

    @IBAction func validate(_ sender: UIButton) {
        if row1 != row2 {
            finalCreat(row1, row2)
            let rowList = [row1, row2]
            LanguagesList.rowsList = rowList
        } else {
            let missingAlert = UIAlertController(title: "Incorect Values", message: "You need to choose two different languages.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            missingAlert.addAction(cancel)
            
            present(missingAlert, animated: true)
        }
    }
    
    func finalCreat(_ row1: Int, _ row2: Int) {
        self.dismiss(animated: true, completion: nil)
        delegate.SetItemL(langs: "\(LanguagesList.langList[row1])-\(LanguagesList.langList[row2])", l1: row1, l2: row2)
        print("item created")
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LangSelectorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LanguagesList.langList.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return LanguagesList.langList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            row1 = row
            print(row1)
        case 1:
            row2 = row
            print(row2)
        default:
            break
        }
        if row1 != row2 {
            validateButton.alpha = 1
        } else {
            validateButton.alpha = 0.5
        }
    }
}
