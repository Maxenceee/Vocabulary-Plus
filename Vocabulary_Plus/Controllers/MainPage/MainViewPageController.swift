//
//  MainViewPageController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 19/04/2021.
//

import UIKit
import CoreData

protocol MainPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class MainViewPageController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var walkthroughDelegate: MainPageViewControllerDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        view.addSubview(pageControl)
        
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        pageControl.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        pageControl.currentPageIndicatorTintColor = traitCollection.userInterfaceStyle == .light ? .systemGray : .white.withAlphaComponent(0.5)
        pageControl.pageIndicatorTintColor = traitCollection.userInterfaceStyle == .light ? .systemGray3 : .white.withAlphaComponent(0.2)
        pageControl.isUserInteractionEnabled = false
        
        // Créer la première page de la séquence de lancement
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        pageControl.currentPageIndicatorTintColor = traitCollection.userInterfaceStyle == .light ? .systemGray : .white.withAlphaComponent(0.5)
        pageControl.pageIndicatorTintColor = traitCollection.userInterfaceStyle == .light ? .systemGray3 : .white.withAlphaComponent(0.2)
    }
    
    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPage = 0
        control.numberOfPages = LanguagesList.statWordsList.count
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Page view controller data source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MainViewContentContainerViewController).index
        index -= 1
        pageControl.currentPage = index+1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MainViewContentContainerViewController).index
        index += 1
        pageControl.currentPage = index-1
        return contentViewController(at: index)
    }
    
    // MARK: - Page view controller delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? MainViewContentContainerViewController {
                currentIndex = contentViewController.index
                
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    
    
    // MARK: - Helper
    
    func contentViewController(at index: Int) -> MainViewContentContainerViewController? {
        if index < 0 || index >= LanguagesList.statWordsList.count {
            return nil
        }
        
        // Créer un nouveau view controller et passer les données attendues
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "MainViewPageControllerContent") as? MainViewContentContainerViewController {
            
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        
        return nil
    }
    
    // MARK: - Fonctions
    
    func avancerPage(toindex: Int) {
        if toindex != currentIndex {
            currentIndex = toindex
            pageControl.currentPage = currentIndex
            if let nextViewController = contentViewController(at: toindex) {
                setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
            }
        }
    }
}
