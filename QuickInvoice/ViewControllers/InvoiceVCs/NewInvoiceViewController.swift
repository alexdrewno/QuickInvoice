//
//  NewInvoiceViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/18/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

// MARK: - View Controller Properties and Actions
class NewInvoiceViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var invoiceDate: UITextField!
    @IBOutlet weak var invoiceTitle: UITextField!
    @IBOutlet weak var jobDescription: UITextField!
    @IBOutlet weak var estimatedTotalTextField: UITextField!
    @IBOutlet weak var actualTotalTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var chooseAClientButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var invoiceItemsButton: UIButton!
    
    var invoiceItems: [InvoiceItem] = []
    var client: Client?
    var curInvoice: Invoice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    @IBAction func saveInvoice(_ sender: Any) {
        self.saveInvoiceToCoreData()
        
        let alert = UIAlertController(title: "Success!", message: "Your changes have been saved", preferredStyle: UIAlertController.Style.alert)
         
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelAndDismissSelf(_ sender: Any) {
        let alert = UIAlertController(title: "Save changes?", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Don't save", style: .default, handler: { action in
            if self.curInvoice == nil {
                for invoiceItem in self.invoiceItems {
                    deleteInvoiceItem(invoiceItem: invoiceItem)
                }
            }
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            self.saveInvoiceToCoreData()
            self.dismiss(animated: true, completion: nil)
        }))
    
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func chooseAClientButtonAction(_ sender: Any) {

        self.showClientsViewController()
    }
}

// MARK: - Data functions
extension NewInvoiceViewController {
    func saveInvoiceToCoreData() {
        if curInvoice == nil {
            postNewInvoice(date: invoiceDate.text ?? "",
                           title: invoiceTitle.text ?? "",
                           jobDescription: jobDescription.text ?? "",
                           estimatedTotal: Float(estimatedTotalTextField.text ?? "0") ?? 0,
                           actualTotal: Float(actualTotalTextField.text ?? "0") ?? 0,
                           comments: commentTextView.text,
                           invoiceItems: invoiceItems,
                           client: client,
                           curUserInfo: fetchCurUserInformation())
            
            if let inv = fetchInvoice(date: invoiceDate.text ?? "",
                            title: invoiceTitle.text ?? "",
                            client: client) {
                curInvoice = inv
            }
            
        } else {
            updateInvoice(invoice: curInvoice!,
                          date: invoiceDate.text ?? "",
                          title: invoiceTitle.text ?? "",
                          jobDescription: jobDescription.text ?? "",
                          estimatedTotal: Float(estimatedTotalTextField.text ?? "0") ?? 0,
                          actualTotal: Float(actualTotalTextField.text ?? "0") ?? 0,
                          comments: commentTextView.text,
                          invoiceItems: invoiceItems,
                          client: client,
                          curUserInfo: fetchCurUserInformation())
        }
    }
}

// MARK: - Setup
extension NewInvoiceViewController {
    func setup() {
        self.hideKeyboardWhenTappedAround()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1200)
        separatorView.frame.size = CGSize(width: separatorView.frame.width, height: 0.5)

        if curInvoice != nil {
            setupCurInvoice()
        } else {
            setupTitleAndDateLabels()
        }
        
        updateTotalLabels()
    }
    
    func setupCurInvoice() {
        invoiceDate.text = curInvoice!.invoiceDate
        invoiceTitle.text = curInvoice!.invoiceTitle
        estimatedTotalTextField.text = "\(curInvoice!.estimatedTotal)"
        actualTotalTextField.text = "\(curInvoice!.actualTotal)"
        jobDescription.text = "\(curInvoice!.jobDescription ?? "")"
        commentTextView.text = curInvoice!.comment
        self.invoiceItems = curInvoice!.invoiceItems?.array as? [InvoiceItem] ?? []
        
        if invoiceItems.count > 0 {
            invoiceItemsButton.setTitle("\(invoiceItems.count) item(s) added", for: .normal)
            invoiceItemsButton.setTitleColor(.black, for: .normal)
        }
        
        if curInvoice!.client != nil {
            chooseAClientButton.setTitle("\(curInvoice!.client!.clientName ?? "")", for: .normal)
            chooseAClientButton.setTitleColor(.black, for: .normal)
            client = curInvoice!.client
        }
    }
    
    func setupTitleAndDateLabels() {
        let numInvoice = fetchInvoices().count + 1
        invoiceTitle.text = "Invoice \(numInvoice)"
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        invoiceDate.text = formatter.string(from: date)
    }
    
    func updateTotalLabels() {
        var et = 0.0
        var at = 0.0
        
        for item in invoiceItems {
            et += Double(Float(item.estimatedQuantity) * item.item!.itemPrice)
            at += Double(Float(item.actualQuantity) * item.item!.itemPrice)
        }
        
        estimatedTotalTextField.text = String(format: "%.2f", et)
        actualTotalTextField.text = String(format: "%.2f", at)
    }
}


// MARK: - ViewController Flow
extension NewInvoiceViewController {
    func showClientsViewController() {
        let storyboard = UIStoryboard(name: "Clients", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "clientsVC") as! ClientsViewController
        vc.modalPresentationStyle = .popover
        vc.senderVC = self
        
        self.present(vc, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewPDF" {
            let dvc = segue.destination as! PDFPreviewViewController
            let pdfCreator = PDFCreator(title: invoiceTitle.text!,
                                        date: invoiceDate.text!,
                                        jobDescription: jobDescription.text!,
                                        client: client,
                                        items: invoiceItems,
                                        estimatedTotal: estimatedTotalTextField.text!,
                                        actualTotal: actualTotalTextField.text!,
                                        otherComments: commentTextView.text!)
            let csvCreator = CSVCreator(title: invoiceTitle.text!,
                                        date: invoiceDate.text!,
                                        jobDescription: jobDescription.text!,
                                        client: client,
                                        invoiceItems: invoiceItems,
                                        estimatedTotal: estimatedTotalTextField.text!,
                                        actualTotal: actualTotalTextField.text!,
                                        otherComments: commentTextView.text!)
            dvc.pdfCreator = pdfCreator
            dvc.csvCreator = csvCreator
        }
        
        if segue.identifier == "showInvoiceItemsVC" {
            let dvc = segue.destination as! InvoiceItemsViewController
            dvc.senderVC = self
            dvc.invoiceItems = self.invoiceItems
        }
    }
}
