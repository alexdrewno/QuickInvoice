//
//  InvoicesViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

// MARK: - View Controller Properties
class InvoicesViewController: UIViewController {
    @IBOutlet weak var invoiceTableView: UITableView!
    @IBOutlet weak var invoicesSearchBar: UISearchBar!
    
    var invoices: [Invoice] = []
    var filteredInvoices: [Invoice] = []
    var selectedInvoice: Invoice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setup()
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Setup
extension InvoicesViewController {
    func setup() {
        invoiceTableView.delegate = self
        invoiceTableView.dataSource = self
        
        invoicesSearchBar.delegate = self
        
        let nib = UINib(nibName: "InvoiceTableViewCell", bundle: nil)
        invoiceTableView.register(nib, forCellReuseIdentifier: "invoiceTableViewCell")
        
        invoiceTableView.separatorStyle = .none
        
        invoices = fetchInvoices()
        invoices = invoices.sorted(by: { (i1, i2) -> Bool in
            i1.invoiceTitle?.lowercased() ?? "" < i2.invoiceTitle?.lowercased() ?? ""
        })
        filteredInvoices = invoices
    }
}

// MARK: - Search Bar Delegate
extension InvoicesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredInvoices = searchText.isEmpty ? invoices : invoices.filter({ (invoice) -> Bool in
            if invoice.invoiceTitle?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                return true
            }
            if invoice.client?.clientName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                return true
            }
            return false
        })
        invoiceTableView.reloadData()
    }
}

// MARK: - Table View Delegate and Data Source
extension InvoicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredInvoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = invoiceTableView.dequeueReusableCell(withIdentifier: "invoiceTableViewCell") as! InvoiceTableViewCell
        
        if let client = invoices[indexPath.row].client {
            cell.clientNameLabel.text = client.clientName ?? ""
        } else {
            cell.clientNameLabel.text = ""
        }
        
        cell.invoiceTitleLabel.text = filteredInvoices[indexPath.row].invoiceTitle ?? ""
        cell.dateLabel.text = filteredInvoices[indexPath.row].invoiceDate ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteInvoice(invoice: filteredInvoices[indexPath.row])
            filteredInvoices.remove(at: indexPath.row)
            invoiceTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedInvoice = filteredInvoices[indexPath.row]
        showInvoiceDetailVC()
    }
    
}

// MARK: - View Controller Flow
extension InvoicesViewController {
    func showInvoiceDetailVC() {
        let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "newInvoiceVC") as! NewInvoiceViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.curInvoice = selectedInvoice
        
        self.present(vc, animated: true)
    }
}

