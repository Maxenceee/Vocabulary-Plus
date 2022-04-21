//
//  VocViewController.swift
//  Voc+
//
//  Created by Maxence Gama on 02/03/2021.
//

import UIKit
import CoreData

class VocViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchBar.autocorrectionType = .default
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText, scopeButton)
    }
    
    func filterForSearchTextAndScopeButton(_ searchText: String, _ scopeButton: String = "All") {
        
        filteredModels = models.filter { content in
            let scopeMatch = (scopeButton == "All" || content.languages!.lowercased().contains(scopeButton.lowercased()))
            if searchController.searchBar.text != "" {
                let searchTextMatch1 = content.language1!.lowercased().contains(searchText.lowercased())
                let searchTextMatch2 = content.language2!.lowercased().contains(searchText.lowercased())
                let searchTagsMatch = content.tags!.lowercased().contains(searchText.lowercased())
                
                return scopeMatch && (searchTextMatch1 || searchTextMatch2 || searchTagsMatch)
            } else {
                return scopeMatch
            }
        }
        tableView.reloadData()
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    private var models = [LangData]()
    private var filteredModels = [LangData]()
    private var tagModel = [Tags]()
    
    let searchController = UISearchController()
    var refreshControl = UIRefreshControl()
    
    var itemCounter: Int = 0 {
        didSet {
            refreshCounter()
        }
    }
    
    func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.hidesBarsOnSwipe = true
        searchController.searchBar.scopeButtonTitles = LanguagesList.sectionsTitles
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "customCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let counterView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.contentMode = .top
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    override var childForHomeIndicatorAutoHidden: UIViewController? {
//        return LangSelectorViewController()
//    }
//    
//    override var prefersHomeIndicatorAutoHidden: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vocabulary"
        view.addSubview(tableView)
        view.addSubview(counterView)
        
//        clearTagModel()
        
        getAllItems()
        getAllTags()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.frame
//        tableView.frame = view.bounds
        
        counterView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -85).isActive = true
        counterView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        counterView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        counterView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: counterView.topAnchor).isActive = true
        
        initSearchController()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMiracle))
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectPaxiSocket(_:)), name: Notification.Name(rawValue: "showMiracleToAddWords"), object: nil)
        
        tableView.keyboardDismissMode = .onDrag
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.allEvents)
//        self.tableView.addSubview(refreshControl)
        
        tableView.reloadData()
    }
    
    func clearTagModel() {
        for j in models {
            for i in tagModel {
                j.removeFromTagRelationship(i)
                i.removeFromLangItem(j)
                deleteTag(item: i)
            }
            print("deleted")
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        getAllItems()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.refreshControl.endRefreshing()
        })
    }
    
    @objc func refreshCounter() {
        counterView.text = "\(itemCounter) item\(itemCounter > 1 ? "s" : "")"
    }
    
    @objc func disconnectPaxiSocket(_ notification: Notification) {
        self.showMiracle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllTags()
//        clearTagModel()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return filteredModels.count
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        let model: LangData!

        // Configure the cell...
//        if model.tags != nil {
//            cell.detailTextLabel?.text = "\(model.languages!)                            \(model.tags!)"
//        }
//        if indexPath.row == (searchController.isActive ? filteredModels.count : models.count) {
//            cell.langs = "\(searchController.isActive ? filteredModels.count : models.count) items"
//        } else {
//        }
        
        if searchController.isActive {
            model = filteredModels[indexPath.row]
        } else {
            model = models[indexPath.row]
        }
        
        cell.textLabel?.text = (model.language1! + " - " + model.language2!)
        cell.textLabel!.numberOfLines = 0
        cell.detailTextLabel?.text = "\(model.languages!)"
        
//        cell.mainTitle = (model.language1! + " - " + model.language2!)
//        cell.langs = "\(model.languages!)"
//        if model.tagRelationship != nil {
//            cell.tags = "\(model.tags!)"
//            //cell.tags = "\(model.tagRelationship!)"
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == (searchController.isActive ? filteredModels.count : models.count) {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        print(indexPath.row)
        let item: LangData!
        if searchController.isActive {
            item = filteredModels[indexPath.row]
        } else {
            item = models[indexPath.row]
        }
        print(item.languages!)
        var langue1 = ""
        var langue2 = ""
        var adding = true
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
        let sheet = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = langue1
                textfield.text = item.language1
                textfield.autocorrectionType = .default
            })
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = langue2
                textfield.text = item.language2
                textfield.autocorrectionType = .default
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
//                guard let field = alert.textFields?.first, let newtext = field.text, !newtext.isEmpty else {
//                    return
//                }
//                guard let field2 = alert.textFields?.last, let newtext2 = field2.text, !newtext2.isEmpty else {
//                    return
//                }
                let field = alert.textFields?.first
                let field2 = alert.textFields?.last
                
                let newtext = field!.text
                let newtext2 = field2!.text
                
                if newtext!.isEmpty || newtext2!.isEmpty {
                    print("Missing elements")
                    let missingAlert = UIAlertController(title: "Missing elements", message: "You need to fill all fields", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
                        field!.text = item.language1
                        field2!.text = item.language2
                        self!.present(alert, animated: true)
                    })
                    
                    missingAlert.addAction(cancel)
                    
                    self!.present(missingAlert, animated: true)
                } else {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                    self?.updateItem(item: item, newlanguage1: newtext!, newlanguage2: newtext2!, newlanguages: item.languages!)
                    print("Item updated")
                }
            }))
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }))
        
        present(sheet, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addTags = addingTagsAction(at: indexPath)
        let removeTags = removeTags(at: indexPath)
        return UISwipeActionsConfiguration(actions: [addTags, removeTags])
    }
    
    func addingTagsAction(at indexPath: IndexPath) -> UIContextualAction {
        let item: LangData!
        if searchController.isActive {
            item = filteredModels[indexPath.row]
        } else {
            item = models[indexPath.row]
        }
        let action = UIContextualAction(style: .destructive, title: "Tags", handler: { (action, view, completition) in
            let alert = UIAlertController(title: "Add Tag", message: "Add tag to your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = "Tags"
                textfield.text = ""
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
                let field = alert.textFields?.first
                
                let text = field!.text
                
                if !text!.isEmpty {
                    self?.addTag(item: item, tagname: text!)
                    print("Item updated")
                } else {
                    print("Missing element")
                    let missingAlert = UIAlertController(title: "Missing element", message: "You need to fill the field", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
                        field!.text = item.language1
                        self!.present(alert, animated: true)
                    })
                    
                    missingAlert.addAction(cancel)
                    
                    self!.present(missingAlert, animated: true)
                }
            }))
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            
            completition(true)
        })
        action.image = UIImage(systemName: "tag")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
        action.backgroundColor = .systemBlue
        
        return action
    }
    
    func removeTags(at indexPath: IndexPath) -> UIContextualAction {
        let item: LangData!
        if searchController.isActive {
            item = filteredModels[indexPath.row]
        } else {
            item = models[indexPath.row]
        }
        let action = UIContextualAction(style: .destructive, title: "RemoveTags", handler: { (action, view, completition) in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            print("remove action")
            
            completition(true)
        })
        action.image = UIImage(systemName: "tag.slash.fill")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
        action.backgroundColor = .systemRed
        
        return action
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let item = models[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completition) in
            self.deleteItem(item: item)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            completition(true)
        })
        action.image = UIImage(systemName: "trash")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
        action.backgroundColor = .red
        
        return action
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let item: LangData!
        if searchController.isActive {
            item = filteredModels[indexPath.row]
        } else {
            item = models[indexPath.row]
        }
        var langue1 = ""
        var langue2 = ""
        var adding = true
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
        let action = UIContextualAction(style: .destructive, title: "Edit", handler: { (action, view, completition) in
            let alert = UIAlertController(title: "Edit item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = langue1
                textfield.text = item.language1
                textfield.autocorrectionType = .default
            })
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = langue2
                textfield.text = item.language2
                textfield.autocorrectionType = .default
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
//                guard let field = alert.textFields?.first, let newtext = field.text, !newtext.isEmpty else {
//                    return
//                }
//                guard let field2 = alert.textFields?.last, let newtext2 = field2.text, !newtext2.isEmpty else {
//                    return
//                }
                
                let field = alert.textFields?.first
                let field2 = alert.textFields?.last
                
                let newtext = field!.text
                let newtext2 = field2!.text
                
                if !newtext!.isEmpty && !newtext2!.isEmpty {
                    self?.updateItem(item: item, newlanguage1: newtext!, newlanguage2: newtext2!, newlanguages: item.languages!)
                    print("Item updated")
                } else {
                    print("Missing elements")
                    let missingAlert = UIAlertController(title: "Missing elements", message: "You need to fill all fields", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
                        field!.text = item.language1
                        field2!.text = item.language2
                        self!.present(alert, animated: true)
                    })
                    
                    missingAlert.addAction(cancel)
                    
                    self!.present(missingAlert, animated: true)
                }
            }))
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            
            completition(true)
        })
        action.image = UIImage(systemName: "ellipsis.circle")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
        action.backgroundColor = .orange
        
        return action
    }
    
    @objc private func didTapAdd(languages: String, r1: Int, r2: Int) {
        let alert = UIAlertController(title: "New item", message: "Create new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textfield in
            textfield.placeholder = LanguagesList.langList[r1]
            textfield.autocorrectionType = .default
        })
        alert.addTextField(configurationHandler: { textfield in
            textfield.placeholder = LanguagesList.langList[r2]
            textfield.autocorrectionType = .default
        })
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
//            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
//                return
//            }
//            guard let field2 = alert.textFields?.last, let text2 = field2.text, !text.isEmpty else {
//                return
//            }
            let field = alert.textFields?.first
            let field2 = alert.textFields?.last
            
            let text = field!.text
            let text2 = field2!.text
            
            if !text!.isEmpty && !text2!.isEmpty {
                self?.createItem(language1: text!,
                                 language2: text2!,
                                 languages: languages)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self?.getAllTags()
                })
                
                print("item created")
            } else {
                print("Missing elements")
                let missingAlert = UIAlertController(title: "Missing elements", message: "You need to fill all fields", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
                    self!.present(alert, animated: true)
                })
                
                missingAlert.addAction(cancel)
                
                self!.present(missingAlert, animated: true)
            }
        }))
        
        let cancel = UIAlertAction(title: "Back", style: .cancel, handler: { [weak self] _ in
            alert.dismiss(animated: true, completion: {
                self!.showMiracle()
            })
        })
        
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @objc func showMiracle() {
        let slide = LangSelectorViewController()
        slide.modalPresentationStyle = .custom
        slide.transitioningDelegate = self
        slide.delegate = self
        self.present(slide, animated: true, completion: nil)
    }
    
    func getAllItems() {
        do {
            let request = LangData.fetchRequest() as NSFetchRequest<LangData>
            
            let sort = NSSortDescriptor(key: "languages", ascending: true)
            request.sortDescriptors = [sort]
            
            models = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.itemCounter = self.models.count
                print("table reloaded")
            }
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
    func getAllTags() {
        do {
            let request = Tags.fetchRequest() as NSFetchRequest<Tags>
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            tagModel = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("table reloaded")
            }
//            print(tagModel)
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
    func createItem(language1: String, language2: String, languages: String) {
        let newItem = LangData(context: context)
        newItem.language1 = language1
        newItem.language2 = language2
        newItem.languages = languages
        newItem.tags = ""
        
        do {
            try context.save()
            getAllItems()
            if UserDefaults.standard.bool(forKey: "isCustomContent") {
                UserDefaults.standard.setValue(false, forKey: "isCustomContent")
            }
        } catch {
            print("ERROR: Enable to save item")
        }
    }
    
    func deleteItem(item: LangData) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
            if UserDefaults.standard.bool(forKey: "isCustomContent") {
                UserDefaults.standard.setValue(false, forKey: "isCustomContent")
            }
        } catch {
            print("ERROR: Enable to delete item")
        }
    }
    
    func updateItem(item: LangData, newlanguage1: String, newlanguage2: String, newlanguages: String) {
        item.language1 = newlanguage1
        item.language2 = newlanguage2
        item.languages = newlanguages
        
        do {
            try context.save()
            getAllItems()
        } catch {
            print("ERROR: Enable to update item")
        }
    }
    
    func addTag(item: LangData, tagname: String) {
        if tagModel.count > 1 {
            for i in tagModel {
                if i.name == tagname {
                    print("tag amready exist")
                    i.addToLangItem(item)
                } else {
                    print("new tag")
                    let newTag = Tags(context: context)
                    newTag.name = tagname
                    item.addToTagRelationship(newTag)
                }
            }
        } else {
            print("context empty")
            let newTag = Tags(context: context)
            newTag.name = tagname
            item.addToTagRelationship(newTag)
        }
        
        print(tagModel)
        /*
        if item.tags != nil  && item.tags != "" {
            item.tags = "\(item.tags!), #\(tags)"
        } else {
            item.tags = "#\(tags)"
        }
        
        LanguagesList.tagsList.append("#\(tags)")*/
        
        do {
            try context.save()
            getAllTags()
            getAllItems()
//            print(tagModel, item)
        } catch {
            print("ERROR: Enable to add item tags")
        }
    }
    
    func deleteTag(item: Tags) {
        context.delete(item)
        
        do {
            try context.save()
            getAllTags()
        } catch {
            print("ERROR: Enable to delete item")
        }
    }
}

extension VocViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension VocViewController: SetItemLanguages {
    func SetItemL(langs: String, l1: Int, l2: Int) {
        print("languages selected : \(langs)")
        didTapAdd(languages: langs, r1: l1, r2: l2)
    }
}
