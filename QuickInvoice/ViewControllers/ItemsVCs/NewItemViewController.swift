//
//  NewItemViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class NewItemViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var itemKeyTextField: UITextField!
    
    var senderVC: ItemsViewController!
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishedEditing(_ sender: Any) {
        var itemPrice: Float = 0
                 
        if priceTextField.text!.count != 0 {
            itemPrice = (priceTextField.text! as NSString).floatValue.rounded(toPlaces: 2)
        }
        
        if item != nil {
            updateItem(item: self.item!,
                       itemName: itemNameTextField.text!,
                       itemDescription: descriptionTextView.text,
                       itemPrice: itemPrice,
                       itemKey: itemKeyTextField.text!)
        } else {
            postNewItem(itemName: itemNameTextField.text!,
                        itemDescription: descriptionTextView.text,
                        itemPrice: itemPrice,
                        itemKey: itemKeyTextField.text!)
        }
        
        self.dismiss(animated: true) {
            self.senderVC.selectedItem = nil
            self.senderVC.updateItems()
            self.senderVC.itemsTableView.reloadData()
        }
    }
    
}

extension NewItemViewController {
    func setup() {
        self.isModalInPresentation = true
        self.hideKeyboardWhenTappedAround()
        
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        priceTextField.keyboardType = .numbersAndPunctuation
        itemKeyTextField.delegate = self
        priceTextField.delegate = self
        
        if item != nil {
            descriptionTextView.text = item!.itemDescription
            itemNameTextField.text = item!.itemName
            priceTextField.text = String(format: "%.2f", item!.itemPrice)
            itemKeyTextField.text = item!.itemKey
            
        }
    }
}
