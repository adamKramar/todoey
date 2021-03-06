//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Adam Kramar on 24/03/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        if #available(iOS 13.0, *) {
            if let color = UIColor(hexString: "#1d9bf6") {
                let contrastColor = ContrastColorOf(color, returnFlat: true)
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColor]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColor]
                navBarAppearance.backgroundColor = color
                navigationBar.standardAppearance = navBarAppearance
                navigationBar.scrollEdgeAppearance = navBarAppearance
            }
        }
    }
    
    //MARK: - Add New Category
    @IBAction func AddAction(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            if let categoryName = textField.text {
                newCategory.name = categoryName
                newCategory.color = UIColor.randomFlat().hexValue()
                self.saveCategory(newCategory)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        if let color = UIColor(hexString: categoryArray?[indexPath.row].color ?? "#1d9bf6") {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItems" {
            let destinationVC = segue.destination as! ToDoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
        }
    }
    
    //MARK: - Data Manipulation Methods
    func saveCategory(_ category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                if let category = self.categoryArray?[indexPath.row] {
                    self.realm.delete(category)
                }
            }
        } catch {
            print("Error delete item: \(error)")
        }
    }
}
