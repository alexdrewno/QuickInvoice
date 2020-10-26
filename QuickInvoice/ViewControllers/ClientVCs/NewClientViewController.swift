//
//  NewClientViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class NewClientViewController: UIViewController {
    @IBOutlet weak var clientNameTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var restofAddressTextField: UITextField!
    @IBOutlet weak var clientEmailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var selectButton: UIButton!
    
    var senderVC: ClientsViewController!
    var baseVC: NewInvoiceViewController!
    
    var client: Client?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @IBAction func dismissPopover(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneEditing(_ sender: Any) {
        self.handleUpdateClient()
        self.dismiss(animated: true, completion: {
            self.senderVC.selectedClient = nil
            self.senderVC.updateClients()
            self.senderVC.clientsTableView.reloadData()
        })
    }
    
    @IBAction func selectClient(_ sender: Any) {
        baseVC.chooseAClientButton.setTitle(clientNameTextField.text!, for: .normal)
        baseVC.chooseAClientButton.setTitleColor(.black, for: .normal)
        handleUpdateClient()
        
        baseVC.client = getClient(email: clientEmailTextField.text!,
                                  clientName: clientNameTextField.text!,
                                  restofAddress: restofAddressTextField.text!,
                                  streetAddress: streetAddressTextField.text!,
                                  telephone: phoneNumberTextField.text!)
        
        self.dismiss(animated: true) {
            self.senderVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleUpdateClient() {
        if client != nil {
            updateClient(client: client!,
                         email: clientEmailTextField.text!,
                         clientName: clientNameTextField.text!,
                         restofAddress: restofAddressTextField.text!,
                         streetAddress: streetAddressTextField.text!,
                         telephone: phoneNumberTextField.text!)
        } else {
            postNewClient(email: clientEmailTextField.text!,
                          clientName: clientNameTextField.text!,
                          restofAddress: restofAddressTextField.text!,
                          streetAddress: streetAddressTextField.text!,
                          telephone: phoneNumberTextField.text!)
        }
        
    }
}

extension NewClientViewController {
    func setup() {
        if baseVC != nil {
            selectButton.isHidden = false
        } else {
            selectButton.isHidden = true
        }
        
        if client != nil {
            clientNameTextField.text = client!.clientName
            clientEmailTextField.text = client!.email
            restofAddressTextField.text = client!.restofAddress
            streetAddressTextField.text = client!.streetAddress
            phoneNumberTextField.text = client!.telephone
        }
    }
}
