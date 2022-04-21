//
//  WalkthroughPageViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 03/04/2021.
//

import UIKit
import CoreData

protocol WalkthroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // Créer la première page de la séquence de lancement
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Page view controller data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    // MARK: - Page view controller delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                currentIndex = contentViewController.index
                
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
    
    // MARK: - Helper (Aide)
    
    func contentViewController(at index: Int, isreversed: Bool = false) -> WalkthroughContentViewController? {
        if index < 0 || index >= LanguagesList.shuffledModel.count {
            return nil
        }
        
        // Créer un nouveau view controller et passer les données attendues
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            let item = LanguagesList.shuffledModel[index]
            
            var adding = isreversed ? true : false
            var langue = ""
            for i in item.languages! {
                if adding {
                    if i != "-" {
                        langue += String(i)
                    }
                }
                if i == "-" {
                    adding = isreversed ? false : true
                }
            }
            var langue1 = ""
            var langue2 = ""
            adding = true
            for i in item.languages! {
                if adding {
                    if i != "-" {
                        langue1 += String(i)
                    }
                } else {
                    if i != "-" {
                        langue2 += String(i)
                    }
                }
                if i == "-" {
                    adding = false
                }
            }
            
            var spaceCount = 0
            var sequence = isreversed ? item.language2! : item.language1!
            if sequence.last == " " {
                sequence.removeLast()
                print("space remove: \(sequence)")
            }
            for i in sequence {
                if i == " " {
                    spaceCount += 1
                }
            }
            print("\(spaceCount) space\(spaceCount > 1 ? "s" : "")")
            
            pageContentViewController.titleLabel.text = "\(!isreversed ? langue1 : langue2)-\(!isreversed ? langue2 : langue1)".localized()
            pageContentViewController.sentenseLabel.text = isreversed ? item.language2 : item.language1
            pageContentViewController.ordersLabel.text = "Translate the following word\(spaceCount >= 1 ? "s" : "") into \(langue.localized()) :"
            
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        
        return nil
    }
    
    // MARK: - Fonctions
    
    func avancerPage(isreversed: Bool) {
        currentIndex += 1
        print(isreversed)
        if let nextViewController = contentViewController(at: currentIndex, isreversed: isreversed) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}
