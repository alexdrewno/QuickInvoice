//
//  InvoiceItemsViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/21/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class InvoiceItemsViewController: UIViewController {
    @IBOutlet weak var invoiceItemsTableView: UITableView!
    @IBOutlet weak var estimatedTotalLabel: UILabel!
    @IBOutlet weak var actualTotalLabel: UILabel!
    
    var senderVC: NewInvoiceViewController!
    var invoiceItems: [InvoiceItem] = []
    var selectedInvoiceItem: InvoiceItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        if invoiceItems.count > 0 {
            updateSenderVCItems()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateSenderVCItems()
    }
    
    @IBAction func addNewInvoiceItem(_ sender: Any) {
        selectedInvoiceItem = nil
        performSegue(withIdentifier: "showNewInvoiceItem", sender: self)
    }
}

extension InvoiceItemsViewController {
    func setup() {
        setupTableView()
        updateLabels()
    }
    
    func setupTableView() {
        invoiceItemsTableView.delegate = self
        invoiceItemsTableView.dataSource = self
        
        let nib = UINib(nibName: "InvoiceItemTableViewCell", bundle: nil)
        invoiceItemsTableView.register(nib, forCellReuseIdentifier: "invoiceItemCell")
        invoiceItemsTableView.separatorStyle = .none
    }
    
    func updateSenderVCItems() {
        senderVC.invoiceItems = self.invoiceItems
        senderVC.invoiceItemsButton.setTitle("\(invoiceItems.count) items added", for: .normal)
        senderVC.invoiceItemsButton.setTitleColor(.black, for: .normal)
        senderVC.updateTotalLabels()
    }
    
    func updateLabels() {
        var et = 0.0
        var at = 0.0
        
        for item in invoiceItems {
            et += Double(Float(item.estimatedQuantity) * item.item!.itemPrice)
            at += Double(Float(item.actualQuantity) * item.item!.itemPrice)
        }
        
        estimatedTotalLabel.text = "$" + String(format: "%.2f", et)
        actualTotalLabel.text = "$" + String(format: "%.2f", at)
    }
}

extension InvoiceItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoiceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = invoiceItemsTableView.dequeueReusableCell(withIdentifier: "invoiceItemCell") as! InvoiceItemTableViewCell
        
        cell.itemNameLabel.text = invoiceItems[indexPath.row].item?.itemName ?? ""
        cell.itemPriceLabel.text = "$" + String(format: "%.2f", invoiceItems[indexPath.row].item?.itemPrice ?? 0.0)
        cell.actualQuantityLabel.text = "\(invoiceItems[indexPath.row].actualQuantity)"
        cell.estimatedQuantityLabel.text = "\(invoiceItems[indexPath.row].estimatedQuantity)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedInvoiceItem = invoiceItems[indexPath.row]
        performSegue(withIdentifier: "showNewInvoiceItem", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteInvoiceItem(invoiceItem: invoiceItems[indexPath.row])
            invoiceItems.remove(at: indexPath.row)
            invoiceItemsTableView.reloadData()
        }
    }
}

extension InvoiceItemsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewInvoiceItem" {
            let dvc = segue.destination as! NewInvoiceItemViewController
            dvc.senderVC = self
            if let sc = selectedInvoiceItem {
                dvc.previousInvoiceItem = sc
            }
        }
    }
}
