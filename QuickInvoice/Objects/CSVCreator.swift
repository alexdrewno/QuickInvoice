//
//  CSVCreator.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 10/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class CSVCreator: NSObject {
    var title: String
    var date: String
    var jobDescription: String
    var client: Client?
    var invoiceItems: [InvoiceItem]
    var estimatedTotal: String
    var actualTotal: String
    var otherComments: String
    var curUserInfo: UserInformation?
    
    init(title: String?,
         date: String?,
         jobDescription: String?,
         client: Client?,
         invoiceItems: [InvoiceItem]?,
         estimatedTotal: String?,
         actualTotal: String?,
         otherComments: String?) {
        self.title = title ?? ""
        self.date = date ?? ""
        self.jobDescription = jobDescription ?? ""
        self.client = client
        self.invoiceItems = invoiceItems ?? []
        self.estimatedTotal = estimatedTotal ?? ""
        self.actualTotal = actualTotal ?? ""
        self.otherComments = otherComments ?? ""
        
        self.curUserInfo = fetchCurUserInformation()
    }
    
    //MARK: - Items CSV functions
    static func shareItemsCSV(items: [Item], sourceVC: UIViewController) {
        let csvString = createItemsCSV(items: items)
        
        let fileName = "Items.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            if path != nil {
                let avc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                sourceVC.present(avc, animated: true, completion: nil)
            }
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    static func createItemsCSV(items: [Item]) -> String{
        var csvString = ""
        csvString += "Name,Key,Description,Price\n"
        
        for i in items {
            csvString += "\(i.itemName ?? ""),\(i.itemKey ?? ""),\(i.itemDescription ?? ""),\(String(i.itemPrice))\n"
        }
        
        return csvString
    }
    
    //MARK: - Clients CSV functions
    static func shareClientsCSV(clients: [Client], sourceVC: UIViewController) {
        let csvString = createClientsCSV(clients: clients)
        
        let fileName = "Clients.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            if path != nil {
                let avc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                sourceVC.present(avc, animated: true, completion: nil)
            }
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    static func createClientsCSV(clients: [Client]) -> String {
        var csvString = ""
        csvString += "Client Name, Email, Telephone, StreetAddress, RestOfAddress\n"
        
        for c in clients {
            csvString += "\(c.clientName ?? ""),\(c.email ?? ""),\(c.telephone ?? ""),\(c.streetAddress?.filter { !",".contains($0) } ?? ""),\(c.restofAddress?.filter { !",".contains($0) } ?? "")\n"
        }
        
        return csvString
    }
    
    //MARK: - Invoice CSV functions
    func shareInvoiceCSV(sourceVC: UIViewController, sourceView: UIView) {
        let fileName = "\(title).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let csvText = createInvoiceCSVString()
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            if path != nil {
                let avc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                avc.popoverPresentationController?.sourceView = sourceView
                sourceVC.present(avc, animated: true, completion: nil)
            }
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    private func createInvoiceCSVString() -> String {
        var csvString = ""
        
        csvString += createInvoiceHeader()
        csvString += createInvoiceBody()
        csvString += createInvoiceFooter()
        
        return csvString
    }
    
    private func createInvoiceHeader() -> String {
        var headerString = ""

        // TODO: Warning that cur user info was not set therefore no header
        // TODO: Check for commas beyond street address and rest of address
        
        if let cui = curUserInfo {
            headerString += "\(cui.name ?? ""), , \(title), , Date:, \(date)\n"
            headerString += "\(cui.streetAddress?.filter { !",".contains($0) } ?? "")\n"
            headerString += "\(cui.restofAddress?.filter { !",".contains($0) } ?? ""), , Service ordered by: , \(client?.clientName ?? "")\n"
            headerString += "\(cui.telephone ?? ""), , telephone:, \(client?.telephone ?? "") \n"
            headerString += "Email: \(cui.email ?? ""), , email:, \(client?.email ?? "")\n\n"
            headerString += "Job Description: , \(jobDescription)\n\n"
            headerString += " , , , , , ,  \n"
            headerString += "Item Name, Description, Unit Price, Estimate QTY, Total, Actual QTY, Total\n\n"
        }
        
        return headerString
    }
    
    private func createInvoiceBody() -> String {
        var bodyString = ""

        for item in invoiceItems {
            let estimatedItemCost = item.item?.itemPrice ?? 0 * Float(item.estimatedQuantity)
            let actualItemCost = item.item?.itemPrice ?? 0 * Float(item.actualQuantity)
            
            bodyString += "\(item.item?.itemName ?? ""), \(item.item?.itemDescription ?? ""), $\(String(format: "%.2f", item.item?.itemPrice ?? 0)), "
            bodyString += "\(item.estimatedQuantity), $\(String(format: "%.2f", estimatedItemCost)), \(item.actualQuantity), $\(String(format: "%.2f", actualItemCost))\n"
        }

        return bodyString
    }
    
    private func createInvoiceFooter() -> String {
        var footerString = ""

        footerString += "\n\n\n"
        footerString += " , , , TOTAL COST, $\(estimatedTotal), , $\(actualTotal)\n\n"

        return footerString
    }
}
