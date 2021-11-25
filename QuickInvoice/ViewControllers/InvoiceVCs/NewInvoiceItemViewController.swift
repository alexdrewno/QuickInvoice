//
//  NewInvoiceItemViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/21/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewInvoiceItemViewController: UIViewController {
    
    @IBOutlet weak var estimatedQuantityTextField: UITextField!
    @IBOutlet weak var actualQuantityTextField: UITextField!
    @IBOutlet weak var chooseSavedItemButton: UIButton!
    @IBOutlet weak var itemDescriptionTextView: UITextView!
    var previousInvoiceItem: InvoiceItem?
    var selectedItem: Item?
    var senderVC: InvoiceItemsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseSavedItemButtonAction(_ sender: Any) {
        showItemsViewController()
    }
    
    @IBAction func saveAndDismiss(_ sender: Any) {
        
        if selectedItem != nil && previousInvoiceItem == nil {
            let entity = NSEntityDescription.entity(forEntityName: "InvoiceItem", in: managedContext)
            let newInvoiceItem = NSManagedObject(entity: entity!, insertInto: managedContext) as! InvoiceItem
            
            newInvoiceItem.setValue(selectedItem, forKey: "item")
            newInvoiceItem.setValue(Int16(actualQuantityTextField.text ?? "0") ?? 0, forKey: "actualQuantity")
            newInvoiceItem.setValue(Int16(estimatedQuantityTextField.text ?? "0") ?? 0, forKey: "estimatedQuantity")
            newInvoiceItem.setValue(itemDescriptionTextView.text ?? "", forKey: "itemDescription")
            
            save()
            
            senderVC.invoiceItems.append(newInvoiceItem)
            senderVC.invoiceItemsTableView.reloadData()
        } else if previousInvoiceItem != nil && selectedItem != nil {
            previousInvoiceItem!.setValue(selectedItem, forKey: "item")
            previousInvoiceItem!.setValue(Int16(actualQuantityTextField.text ?? "0") ?? 0, forKey: "actualQuantity")
            previousInvoiceItem!.setValue(Int16(estimatedQuantityTextField.text ?? "0") ?? 0, forKey: "estimatedQuantity")
            previousInvoiceItem!.setValue(itemDescriptionTextView.text ?? "", forKey: "itemDescription")
            
            save()
        
            senderVC.updateLabels()
            senderVC.invoiceItemsTableView.reloadData()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewInvoiceItemViewController {
    func setup() {
        if let pii = previousInvoiceItem {
            selectedItem = pii.item
            chooseSavedItemButton.setTitle(selectedItem!.itemName ?? "", for: .normal)
            chooseSavedItemButton.setTitleColor(.black, for: .normal)
            estimatedQuantityTextField.text = "\(pii.estimatedQuantity)"
            actualQuantityTextField.text = "\(pii.actualQuantity)"
        }
        itemDescriptionTextView.layer.borderWidth = 1
        itemDescriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        itemDescriptionTextView.layer.cornerRadius = 3
    }
}

extension NewInvoiceItemViewController {
    func showItemsViewController() {
        let storyboard = UIStoryboard(name: "Items", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "itemsVC") as! ItemsViewController
        vc.modalPresentationStyle = .popover
        vc.newInvoiceItemVC = self
        vc.isSelectingNewInvoiceItem = true
        
        self.present(vc, animated: true)
    }
}

