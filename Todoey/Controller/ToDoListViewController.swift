//
//  ViewController.swift
//  Todoey
//
//  Created by Adam Kramar on 21/03/2020.
//  Copyright (c) 2020 Adam Kramar. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        if let color =  UIColor(hexString: selectedCategory?.color ?? "#1d9bf6") {
            title = selectedCategory!.name
            if #available(iOS 13.0, *) {
                let contrastColor = ContrastColorOf(color, returnFlat: true)
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColor]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColor]
                navBarAppearance.backgroundColor = color
                searchBar.barTintColor = color
                searchBar.backgroundColor = .white
                navigationBar.standardAppearance = navBarAppearance
                navigationBar.scrollEdgeAppearance = navBarAppearance
                navigationBar.tintColor = contrastColor
            }
        }
    }
    
    //MARK: - Model Manipulation Methods
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                if let item = self.items?[indexPath.row] {
                    self.realm.delete(item)
                }
            }
        } catch {
            print("Error delete item: \(error)")
        }
    }
    
    //MARK: - Add New Items
    @IBAction func AddAction(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let text = textField.text,
                let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = text
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory?.color ?? "#1d9bf6")?
                .darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
        }
        tableView.reloadData()
    }


}

//MARK: - Searchbar Delegate
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            items = items?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

