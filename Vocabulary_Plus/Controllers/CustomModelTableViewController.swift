//
//  CustomModelTableViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 06/04/2021.
//

import UIKit
import CoreData

class CustomModelTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    let searchController = UISearchController()
    
    private var models = [LangData]()
    private var filteredModels = [LangData]()
    
    var tempContentList = [] as [Bool]

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
        
        fullTempList()
        
        tableView.reloadData()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        dismissAndSave()
    }
    
    func fullTempList() {
        if UserDefaults.standard.bool(forKey: "isCustomContent") {
            print("custom")
            if UserDefaults.standard.object(forKey: "customTempContentList") != nil {
                tempContentList = UserDefaults.standard.object(forKey: "customTempContentList") as! Array<Bool>
            } else {
                for _ in 0...models.count-1 {
                    tempContentList.append(false)
                }
            }
        } else {
            print("not custom")
            if models.count > 0 {
                for _ in 0...models.count-1 {
                    tempContentList.append(false)
                }
            }
        }
        print(tempContentList)
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(CustomCell.self, forCellReuseIdentifier: "customCell")
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
        searchController.searchBar.scopeButtonTitles = LanguagesList.sectionsTitles
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
    }
    
    @objc func dismissAndSave() {
        let alert = UIAlertController(title: "Invalid selection", message: "You haven't selected enough items (2 minimum). Your selection wont be saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak self] _ in
            self!.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        LanguagesList.customContentList = []
        for i in 0...models.count-1 {
            if tempContentList[i] == true {
                LanguagesList.customContentList.append(models[i])
            }
        }
        print(LanguagesList.customContentList)
        if LanguagesList.customContentList.count < 2 {
            present(alert, animated: true)
        } else {
            UserDefaults.standard.setValue(true, forKey: "isCustomContent")
            UserDefaults.standard.set(tempContentList, forKey: "customTempContentList")
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "customStartButtonForCustomContent"), object: nil)
            })
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell

        let model: LangData!
        
        if searchController.isActive {
            model = filteredModels[indexPath.row]
        } else {
            model = models[indexPath.row]
        }
        
//        cell.textLabel?.text = "\(model.language1!) - \(model.language2!)"
        
        cell.mainTitle = (model.language1! + " - " + model.language2!)
        cell.langs = "\(model.languages!)"
        if tempContentList[indexPath.row] == true {
            cell.isImageSet = true
        } else {
            cell.isImageSet = false
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60//UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
        
        if tempContentList[indexPath.row] == false {
            tempContentList[indexPath.row] = true
            if isModalInPresentation == false {
                self.isModalInPresentation = true
            }
            print(tempContentList)
        } else {
            tempContentList[indexPath.row] = false
            print(tempContentList)
        }
        
        if tempContentList[indexPath.row] == true {
            cell.isImageSet = true
        } else {
            cell.isImageSet = false
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
//        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
