//
//  ItemsViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class ItemsViewController: UIViewController {
    @IBOutlet weak var itemsTableView: UITableView!
    var newInvoiceItemVC: NewInvoiceItemViewController!
    var isSelectingNewInvoiceItem = false
    @IBOutlet weak var itemsSearchBar: UISearchBar!
    
    var items: [Item] = []
    var filteredItems: [Item] = []
    var selectedItem: Item? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ItemsViewController {
    func setup() {
        itemsSearchBar.delegate = self
        
        updateItems()
        setupTableView()
    }
    
    func setupTableView() {
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.separatorStyle = .none
        
        let nib = UINib(nibName: "ItemTableViewCell", bundle: nil)
        itemsTableView.register(nib, forCellReuseIdentifier: "itemTableViewCell")
    }
    
    func updateItems() {
        items = fetchItems()
        items = items.sorted(by: { (i1, i2) -> Bool in
            i1.itemName?.lowercased() ?? "" < i2.itemName?.lowercased() ?? ""
        })
        filteredItems = items
    }
}

extension ItemsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = searchText.isEmpty ? items : items.filter({ (item) -> Bool in
            if item.itemName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                return true
            }
            if item.itemKey?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                return true
            }
            return false
        })
        itemsTableView.reloadData()
    }
}

extension ItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemsTableView.dequeueReusableCell(withIdentifier: "itemTableViewCell") as! ItemTableViewCell
        
        cell.itemNameLabel.text = filteredItems[indexPath.row].itemName
        
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if isSelectingNewInvoiceItem {
            newInvoiceItemVC.selectedItem = filteredItems[indexPath.row]
            newInvoiceItemVC.chooseSavedItemButton.setTitle(newInvoiceItemVC.selectedItem!.itemName ?? "", for: .normal)
            newInvoiceItemVC.chooseSavedItemButton.setTitleColor(.black, for: .normal)
            self.dismiss(animated: true, completion: nil)
        } else {
            selectedItem = filteredItems[indexPath.row]
            performSegue(withIdentifier: "showItemsView", sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(item: filteredItems[indexPath.row])
            filteredItems.remove(at: indexPath.row)
            self.itemsTableView.reloadData()
        }
    }
}

//MARK: - Segue
extension ItemsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemsView" {
            let dvc = segue.destination as! NewItemViewController
            dvc.senderVC = self
            dvc.item = selectedItem
        }
    }
}
