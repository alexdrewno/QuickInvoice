//
//  ClientsViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class ClientsViewController: UIViewController {
    @IBOutlet weak var clientsTableView: UITableView!
    var clients: [Client] = []
    var filteredClients: [Client] = []
    var selectedClient: Client? = nil
    var senderVC: NewInvoiceViewController!
    @IBOutlet weak var clientsSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Setup
extension ClientsViewController {
    func setup() {
        clientsSearchBar.delegate = self
        
        updateClients()
        setupTableView()
    }
    
    func setupTableView() {
        clientsTableView.delegate = self
        clientsTableView.dataSource = self
        
        let nib = UINib(nibName: "ClientTableViewCell", bundle: nil)
        clientsTableView.register(nib, forCellReuseIdentifier: "clientTableViewCell")
        
        clientsTableView.separatorStyle = .none
    }
    
    func updateClients() {
        clients = fetchClients()
        clients = clients.sorted(by: { (c1, c2) -> Bool in
            c1.clientName?.lowercased() ?? "" < c2.clientName?.lowercased() ?? ""
        })
        filteredClients = clients
    }
}

extension ClientsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredClients = searchText.isEmpty ? clients : clients.filter({ (client) -> Bool in
            if client.clientName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil {
                return true
            }
            return false
        })
        clientsTableView.reloadData()
    }
}

//MARK: - TableViewDelegate and DataSource
extension ClientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredClients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = clientsTableView.dequeueReusableCell(withIdentifier: "clientTableViewCell") as! ClientTableViewCell
        
        cell.clientNameLabel.text = filteredClients[indexPath.row].clientName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedClient = filteredClients[indexPath.row]
        performSegue(withIdentifier: "showClientView", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteClient(client: filteredClients[indexPath.row])
            filteredClients.remove(at: indexPath.row)
            self.clientsTableView.reloadData()
        }
    }
    
}

//MARK: - Segue
extension ClientsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showClientView" {
            let dvc = segue.destination as! NewClientViewController
            dvc.senderVC = self
            dvc.client = selectedClient
            
            if self.senderVC != nil {
                dvc.baseVC = self.senderVC
            }
        }
    }
}
