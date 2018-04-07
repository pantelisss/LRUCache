//
//  ViewController.swift
//  LRUCache
//
//  Created by Pantelis Giazitsis on 03/23/2018.
//  Copyright (c) 2018 Pantelis Giazitsis. All rights reserved.
//

import UIKit
import LRUCache

private let CELL_ID = "cellId"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Vars
    
    lazy var cache: LRUCache = LRUCache(capacity: 10)
    lazy var dataSource: [String] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Logic
    
    func refresh() {
        dataSource = cache.chacheObjects().compactMap{$0 as? String}
        tableView.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        showNewItemAlert()
    }
    
    // MARK: Helpers
    
    func newItem(withText text: String) -> (String,String) {
        let uuid = UUID()
        
        return (uuid.uuidString , text)
    }
    
    func showNewItemAlert() {
        let alertController = UIAlertController(title: "New Item", message: "Insert new item", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Item Text"
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {[weak self] (_ action: UIAlertAction) -> Void in
            guard let text = alertController.textFields?.first?.text else { return }
            
            guard let newItem = self?.newItem(withText: text) else { return }
            
            self?.cache.setObject(object: newItem.1 as AnyObject, forKey: newItem.0)
            self?.refresh()
        })
        
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)

    }
}

extension ViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) 
        
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
}
