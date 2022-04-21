//
//  MostWrongWordsListView.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 22/04/2021.
//

import Foundation
import UIKit
import CoreData

@IBDesignable
class MostWrongWordsListView: UIView {
    public enum WrongWords {
        static let word1: String = ""
        static let word2: String = ""
        static let word3: String = ""
        static let word4: String = ""
        static let word5: String = ""
        static let wordsSize: CGFloat = 15
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var models = [LangData]()
    var wordList = [LangData]()
    
    override func draw(_ rect: CGRect) {
        getAllItems()
        
        self.addSubview(stackView)
        stackView.addArrangedSubview(wordLabel1)
        stackView.addArrangedSubview(wordLabel2)
        stackView.addArrangedSubview(wordLabel3)
        stackView.addArrangedSubview(wordLabel4)
        stackView.addArrangedSubview(wordLabel5)
        
//        addLinesToLabels()
        
//        fillList()
        wordList = []
        
        if models.count != 0 {
            if models.count >= 5 {
                for i in 0...4 {
                    wordList.append(models[i])
                }
            } else {
                for i in 0...models.count-1 {
                    wordList.append(models[i])
                }
            }
        }
        
        setupLayout()
        
        updateLabels()
        
        addLinesToLabels()
        
//        createLines(rect: rect)
    }
    
    func fillList() {
        print(models)
        wordList = []
        
        for i in models {
            if wordList.count != 0 {
                for j in 0...wordList.count-1 {
                    if i.numOfWrongAnswer >= wordList[j].numOfWrongAnswer {
                        wordList.insert(i, at: j)
                        print("i > \(j)")
                        break
                    } else if wordList.count < 5 {
                        wordList.append(i)
                    }
                }
            } else {
                wordList.append(i)
            }
        }
//        print("wordList : \(wordList) //////////////////")
    }
    
    func updateLabels() {
        if (wordList.count > 0 && wordList[0].numOfWrongAnswer > 0) {
            for i in 0..<5 {
                if (wordList.count > i && wordList[i].numOfWrongAnswer > 0) {
                    labelList(i).text = "\(wordList[i].language1!) - \(wordList[i].language2!)"
                }
            }
//            (wordList.count-1 >= 0 &&  != 0) ?
//            (wordList.count-1 >= 1 && wordList[1].numOfWrongAnswer != 0) ?
//            (wordList.count-1 >= 2 && wordList[2].numOfWrongAnswer != 0) ?
//            (wordList.count-1 >= 3 && wordList[3].numOfWrongAnswer != 0) ?
//            (wordList.count-1 >= 4 && wordList[4].numOfWrongAnswer != 0) ?
        } else {
            labelList(0).text = "Not enough data, do more quizz"
        }
        
    }
    
    func createLines(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        let margin: CGFloat = 10
        
        let linePath = UIBezierPath()

        linePath.move(to: CGPoint(x: margin, y: (height/5)))
        linePath.addLine(to: CGPoint(x: width - margin, y: (height/5)))
        
        linePath.move(to: CGPoint(x: margin, y: 2*(height/5)))
        linePath.addLine(to: CGPoint(x: width - margin, y: 2*(height/5)))
        
        linePath.move(to: CGPoint(x: margin, y: 3*(height/5)))
        linePath.addLine(to: CGPoint(x: width - margin, y: 3*(height/5)))
        
        linePath.move(to: CGPoint(x: margin, y: 4*(height/5)))
        linePath.addLine(to: CGPoint(x: width - margin, y: 4*(height/5)))
        
        linePath.move(to: CGPoint(x: margin, y: 5*(height/5)))
        linePath.addLine(to: CGPoint(x: width - margin, y: 5*(height/5)))

        UIColor.white.withAlphaComponent(0.5).set()
        linePath.lineWidth = 1.0
        linePath.stroke()

    }
    
    func addLinesToLabels() {
        let bgColor = traitCollection.userInterfaceStyle == .light ? UIColor.systemGray3.cgColor : UIColor.systemGray2.cgColor
        
        if (wordList.count > 0) {
            for i in 0..<5 {
                if (wordList.count > i && wordList[i].numOfWrongAnswer > 0) {
                    let bottomLine2 = CALayer()
                    bottomLine2.frame = CGRect(x: 0, y: labelList(i).frame.height - 2, width: labelList(i).frame.width, height: 1)
                    bottomLine2.backgroundColor = UIColor.init(cgColor: bgColor).cgColor
                    labelList(i).layer.addSublayer(bottomLine2)
                }
            }
        } else {
            let bottomLine1 = CALayer()
            bottomLine1.frame = CGRect(x: 0, y: labelList(0).frame.height - 2, width: labelList(0).frame.width, height: 1)
            bottomLine1.backgroundColor = UIColor.init(cgColor: bgColor).cgColor
            labelList(0).layer.addSublayer(bottomLine1)
        }
        
//        let bottomLine2 = CALayer()
//        bottomLine2.frame = CGRect(x: 0, y: wordLabel2.frame.height - 2, width: wordLabel2.frame.width, height: 1)
//        bottomLine2.backgroundColor = UIColor.init(cgColor: bgColor).cgColor
//        wordLabel2.layer.addSublayer(bottomLine2)
//
//        let bottomLine3 = CALayer()
//        bottomLine3.frame = CGRect(x: 0, y: wordLabel3.frame.height - 2, width: wordLabel3.frame.width, height: 1)
//        bottomLine3.backgroundColor = UIColor.init(cgColor: bgColor).cgColor
//        wordLabel3.layer.addSublayer(bottomLine3)
//
//        let bottomLine4 = CALayer()
//        bottomLine4.frame = CGRect(x: 0, y: wordLabel4.frame.height - 2, width: wordLabel4.frame.width, height: 1)
//        bottomLine4.backgroundColor = UIColor.init(cgColor: bgColor).cgColor
//        wordLabel4.layer.addSublayer(bottomLine4)
//
//        let bottomLine5 = CALayer()
//        bottomLine5.frame = CGRect(x: 0, y: wordLabel5.frame.height - 2, width: wordLabel5.frame.width, height: 1)
//        bottomLine5.backgroundColor = UIColor.init(cgColor: bgColor).cgColor
//        wordLabel5.layer.addSublayer(bottomLine5)

        /*
        bottomLine1.frame.size.width = 0
        bottomLine2.frame.size.width = 0
        bottomLine3.frame.size.width = 0
        bottomLine4.frame.size.width = 0
        bottomLine5.frame.size.width = 0
        
        UIView.animate(withDuration: 1, delay: 0, animations: { [self] in
            bottomLine1.frame.size.width = wordLabel1.frame.width
        })
        UIView.animate(withDuration: 1, delay: 0.1, animations: { [self] in
            bottomLine2.frame.size.width = wordLabel2.frame.width
        })
        UIView.animate(withDuration: 1, delay: 0.2, animations: { [self] in
            bottomLine3.frame.size.width = wordLabel3.frame.width
        })
        UIView.animate(withDuration: 1, delay: 0.3, animations: { [self] in
            bottomLine4.frame.size.width = wordLabel4.frame.width
        })
        UIView.animate(withDuration: 1, delay: 0.4, animations: { [self] in
            bottomLine5.frame.size.width = wordLabel5.frame.width
        })*/
    }
    
    override func setNeedsDisplay(_ rect: CGRect) {
        super.setNeedsDisplay(rect)
        setNeedsDisplay()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        addLinesToLabels()
    }
    
    func setupLayout() {
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
    }
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0
        stack.contentMode = .scaleToFill
        stack.isOpaque = false
        stack.isBaselineRelativeArrangement = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let wordLabel1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = WrongWords.word1
        label.font = UIFont.systemFont(ofSize: WrongWords.wordsSize, weight: .medium)
        return label
    }()
    let wordLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = WrongWords.word2
        label.font = UIFont.systemFont(ofSize: WrongWords.wordsSize, weight: .medium)
        return label
    }()
    let wordLabel3: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = WrongWords.word3
        label.font = UIFont.systemFont(ofSize: WrongWords.wordsSize, weight: .medium)
        return label
    }()
    let wordLabel4: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = WrongWords.word4
        label.font = UIFont.systemFont(ofSize: WrongWords.wordsSize, weight: .medium)
        return label
    }()
    let wordLabel5: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = WrongWords.word5
        label.font = UIFont.systemFont(ofSize: WrongWords.wordsSize, weight: .medium)
        return label
    }()
    
    func labelList(_ i: Int) -> UILabel {
        let list = [wordLabel1, wordLabel2, wordLabel3, wordLabel4, wordLabel5]
        return list[i]
    }
    
    func getAllItems() {
        do {
            let request = LangData.fetchRequest() as NSFetchRequest<LangData>
            
            let sort = NSSortDescriptor(key: "numOfWrongAnswer", ascending: false)
            request.sortDescriptors = [sort]
            
            models = try context.fetch(request)
            
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
}
