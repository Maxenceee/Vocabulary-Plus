//
//  TagsModelViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 06/04/2021.
//

import UIKit
import CoreData

class TagsModelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    let searchController = UISearchController()
    
    private var models = [Tags]()
    private var filteredModels = [Tags]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getAllItems()
        
        view.addSubview(tableView)
        title = "Select your quiz content"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.frame
//        tableView.frame = view.bounds
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        initSearchController()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissAndCancel))
        tableView.keyboardDismissMode = .onDrag
        
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
    }

    @IBAction func save(_ sender: Any) {
        dismissAndSave()
    }
    
    @objc func dismissAndSave() {
        let alert = UIAlertController(title: "No selection", message: "You didn't selected any item", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] _ in
            self!.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            
        }))
        
//        LanguagesList.customContentList = []
//        LanguagesList.customContentList = filteredModels
        print(LanguagesList.customContentList)
        if LanguagesList.customContentList.count <= 0 {
            present(alert, animated: true)
        } else {
            UserDefaults.standard.setValue(true, forKey: "isCustomContent")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissAndCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return filteredModels.count
        }
        return models.count
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchBar.autocorrectionType = .default
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText)
    }
    
    func filterForSearchTextAndScopeButton(_ searchText: String) {
        
        filteredModels = models.filter { content in
            if searchController.searchBar.text != "" {
                let searchTagsMatch = content.name!.lowercased().contains(searchText.lowercased())
                
                return (searchTagsMatch)
            } else {
                return false
            }
        }
        tableView.reloadData()
    }
    
    func getAllItems() {
        do {
            let request = Tags.fetchRequest() as NSFetchRequest<Tags>
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            models = try context.fetch(request)
            
            tableView.reloadData()
        } catch {
            print("ERROR: Enable to get items")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell

        let model: Tags!
        
        if searchController.isActive {
            model = filteredModels[indexPath.row]
        } else {
            model = models[indexPath.row]
        }
        
        cell.mainTitle = "\(model.name!)"
        cell.langs = "\(model.langItem!)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let item = models[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completition) in
            self.deleteItem(item: item)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        action.image = UIImage(systemName: "trash")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
        action.backgroundColor = .red
        
        return action
    }
    
    func deleteItem(item: Tags) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            print("ERROR: Enable to delete item")
        }
    }

}
