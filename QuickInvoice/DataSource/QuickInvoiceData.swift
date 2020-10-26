//
//  QuickInvoiceData.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let managedContext = appDelegate.persistentContainer.viewContext

//MARK: - Invoice Coredata Methods
func deleteInvoice(invoice: Invoice) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Invoice")
    request.returnsObjectsAsFaults = true
        
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let invoiceData = data as! Invoice
            if invoiceData == invoice {
                
                for invoiceItem in invoice.invoiceItems ?? [] {
                    deleteInvoiceItem(invoiceItem: invoiceItem as! InvoiceItem)
                    print("deleted")
                }
                
                managedContext.delete(invoiceData)
                
                save()
            }
        }
    } catch {
        print("Failed to update invoice")
    }
}

func updateInvoice(invoice: Invoice,
                   date: String,
                   title: String,
                   jobDescription: String,
                   estimatedTotal: Float,
                   actualTotal: Float,
                   comments: String,
                   invoiceItems: [InvoiceItem],
                   client: Client?,
                   curUserInfo: UserInformation?) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Invoice")
    request.returnsObjectsAsFaults = true
        
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let invoiceData = data as! Invoice
            if invoiceData == invoice {
                invoiceData.invoiceDate = date
                invoiceData.invoiceTitle = title
                invoiceData.jobDescription = jobDescription
                invoiceData.estimatedTotal = estimatedTotal
                invoiceData.actualTotal = actualTotal
                invoiceData.comment = comments
                    
                let invoiceItemsSet = NSOrderedSet(array: invoiceItems)
                invoiceData.setValue(invoiceItemsSet, forKey: "invoiceItems")
                
                invoiceData.client = client
                invoiceData.userInformation = curUserInfo
                
                save()
            }
        }
    } catch {
        print("Failed to update invoice")
    }
}

func fetchInvoice(date: String, title: String, client: Client?) -> Invoice? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Invoice")
    request.returnsObjectsAsFaults = true
        
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let invoiceData = data as! Invoice
            
            if date == invoiceData.invoiceDate
                && title == invoiceData.invoiceTitle
                && client == invoiceData.client {

                return invoiceData
            }
        }
    } catch {
        print("Failed to update invoice")
    }
    return nil
}

func fetchInvoices() -> [Invoice] {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Invoice")
    request.returnsObjectsAsFaults = true
    
    var invoices: [Invoice] = []
    
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            invoices.append(data as! Invoice)
        }
    } catch {
        print("Failed to fetch invoices")
    }
    
    return invoices
}

func postNewInvoice(date: String,
                    title: String,
                    jobDescription: String,
                    estimatedTotal: Float,
                    actualTotal: Float,
                    comments: String,
                    invoiceItems: [InvoiceItem],
                    client: Client?,
                    curUserInfo: UserInformation?) {
    
    let entity = NSEntityDescription.entity(forEntityName: "Invoice", in: managedContext)
    let newInvoice = NSManagedObject(entity: entity!, insertInto: managedContext) as! Invoice
    
    newInvoice.setValue(date, forKey: "invoiceDate")
    newInvoice.setValue(title, forKey: "invoiceTitle")
    newInvoice.setValue(actualTotal, forKey: "actualTotal")
    newInvoice.setValue(estimatedTotal, forKey: "estimatedTotal")
    newInvoice.setValue(comments, forKey: "comment")
    newInvoice.setValue(jobDescription, forKey: "jobDescription")
    
    let invoiceItemsSet = NSOrderedSet(array: invoiceItems)
    newInvoice.setValue(invoiceItemsSet, forKey: "invoiceItems")
    
    if let c = client {
        newInvoice.setValue(c, forKey: "client")
    }
    
    if let u = curUserInfo {
        newInvoice.setValue(u, forKey: "userInformation")
    }
    
    save()
}

func deleteInvoiceItem(invoiceItem: InvoiceItem) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InvoiceItem")
    request.returnsObjectsAsFaults = true

    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let itemData = data as! InvoiceItem
            if itemData == invoiceItem {
                managedContext.delete(itemData)
                save()
                return
            }
        }
    } catch {
        print("Failed to remove invoice item")
    }
}


//MARK: - Item Coredata Methods
func postNewItem(itemName: String, itemDescription: String, itemPrice: Float, itemKey: String) {
    let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)
    let newItem = NSManagedObject(entity: entity!, insertInto: managedContext)
    
    newItem.setValue(itemName, forKey: "itemName")
    newItem.setValue(itemDescription, forKey: "itemDescription")
    newItem.setValue(itemKey, forKey: "itemKey")
    newItem.setValue(itemPrice, forKey: "itemPrice")
    
    save()
}

func fetchItems() -> [Item] {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
    request.returnsObjectsAsFaults = true
    
    var items: [Item] = []
    
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            items.append(data as! Item)
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
    
    return items
}

func deleteItem(item: Item) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
    request.returnsObjectsAsFaults = true

    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let itemData = data as! Item
            if itemData == item {
                managedContext.delete(itemData)
                save()
                return
            }
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
}

func updateItem(item: Item, itemName: String, itemDescription: String, itemPrice: Float, itemKey: String) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
    request.returnsObjectsAsFaults = true
        
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let itemData = data as! Item
            if itemData == item {
                itemData.itemDescription = itemDescription
                itemData.itemName = itemName
                itemData.itemPrice = itemPrice
                itemData.itemKey = itemKey
                
                save()
                return
            }
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
}

//MARK: - Client Coredata Methods
func getClient(email: String, clientName: String, restofAddress: String, streetAddress: String, telephone: String) -> Client? {
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
    request.returnsObjectsAsFaults = true
    
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let clientData = data as! Client
            if clientData.email == email
                && clientData.clientName == clientName
                && clientData.restofAddress == restofAddress
                && clientData.streetAddress == streetAddress
                && clientData.telephone == telephone {
                return clientData
            }
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
    return nil
}

func postNewClient(email: String, clientName: String, restofAddress: String, streetAddress: String, telephone: String) {
    removePreviousCurUserInformation()
    
    let entity = NSEntityDescription.entity(forEntityName: "Client", in: managedContext)
    let curUserInfo = NSManagedObject(entity: entity!, insertInto: managedContext)
    
    curUserInfo.setValue(email, forKey: "email")
    curUserInfo.setValue(clientName, forKey: "clientName")
    curUserInfo.setValue(restofAddress, forKey: "restofAddress")
    curUserInfo.setValue(streetAddress, forKey: "streetAddress")
    curUserInfo.setValue(telephone, forKey: "telephone")

    save()
}

func fetchClients() -> [Client] {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
    request.returnsObjectsAsFaults = true
    
    var clients: [Client] = []
    
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            clients.append(data as! Client)
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
    
    return clients
}

func updateClient(client: Client, email: String, clientName: String, restofAddress: String, streetAddress: String, telephone: String) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
    request.returnsObjectsAsFaults = true

    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let clientData = data as! Client
            if clientData == client {
                clientData.email = email
                clientData.clientName = clientName
                clientData.restofAddress = restofAddress
                clientData.streetAddress = streetAddress
                clientData.telephone = telephone
                
                save()
                return
            }
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
}

func deleteClient(client: Client) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Client")
    request.returnsObjectsAsFaults = true

    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            let clientData = data as! Client
            if clientData == client {
                managedContext.delete(clientData)
                save()
                return
            }
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
}


//MARK: - CurUserInfo Coredata methods

func postCurUserInformation(email: String, name: String, restofAddress: String, streetAddress: String, telephone: String) {
    removePreviousCurUserInformation()
    
    let entity = NSEntityDescription.entity(forEntityName: "UserInformation", in: managedContext)
    let curUserInfo = NSManagedObject(entity: entity!, insertInto: managedContext)
    
    curUserInfo.setValue(email, forKey: "email")
    curUserInfo.setValue(name, forKey: "name")
    curUserInfo.setValue(restofAddress, forKey: "restofAddress")
    curUserInfo.setValue(streetAddress, forKey: "streetAddress")
    curUserInfo.setValue(telephone, forKey: "telephone")

    save()
}

func fetchCurUserInformation() -> UserInformation? {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInformation")
    request.returnsObjectsAsFaults = true
    
    var curUserInformation: UserInformation? = nil
    
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            curUserInformation = data as? UserInformation
        }
    } catch {
        print("Failed to remove previous cur user information")
    }
    
    return curUserInformation
}

func removePreviousCurUserInformation() {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInformation")
    
    request.returnsObjectsAsFaults = true
    
    do {
        let result = try managedContext.fetch(request)
        for data in result as! [NSManagedObject] {
            managedContext.delete(data)
      }
    } catch {
        print("Failed to remove previous cur user information")
    }
}

func save() {
    do {
        try managedContext.save()
    } catch {
        print("Couldn't save current user info")
    }
}

// MARK: - All Data Manipulation

public func clearAllCoreData() {
    let entities = appDelegate.persistentContainer.managedObjectModel.entities
    entities.compactMap({ $0.name }).forEach(clearDeepObjectEntity)
}

private func clearDeepObjectEntity(_ entity: String) {
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

    do {
        try managedContext.execute(deleteRequest)
        try managedContext.save()
    } catch {
        print ("There was an error")
    }
}
