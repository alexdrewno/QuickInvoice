//
//  SettingsViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 10/20/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var communicationWithUsImageView: UIImageView!
    @IBOutlet weak var extraOptionsImageView: UIImageView!
    @IBOutlet weak var dangerZoneImageView: UIImageView!
    @IBOutlet weak var includeEstimatedCostsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Communicate with us section
    @IBAction func sendFeedbackButtonAction(_ sender: Any) {
        let email = "adrewno14@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
    @IBAction func rateAndReviewButtonAction(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }
    
    // MARK: - Extra Options section
    @IBAction func includeEstimatedCostsButtonAction(_ sender: Any) {
        var isECIncluded = UserDefaults.standard.bool(forKey: "estimatedCosts")

        isECIncluded = !isECIncluded
        
        setupButtonTitle(boolVal: isECIncluded)
        
        UserDefaults.standard.set(isECIncluded, forKey: "estimatedCosts")
    }
    
    @IBAction func exportClientDataButtonAction(_ sender: Any) {
        CSVCreator.shareClientsCSV(clients: fetchClients(), sourceVC: self)
    }
    
    @IBAction func exportItemDataButtonAction(_ sender: Any) {
        CSVCreator.shareItemsCSV(items: fetchItems(), sourceVC: self)
    }
    
    // MARK: - Danger Zone section
    @IBAction func clearAllSavedDataButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "Careful!", message: "You are about to remove all of the data in Quick Invoice. Are you sure?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
            clearAllCoreData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SettingsViewController {
    func setup() {
        setupButtonTitle(boolVal: UserDefaults.standard.bool(forKey: "estimatedCosts"))
    }
    
    func setupButtonTitle(boolVal: Bool) {
        if boolVal {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Include estimated costs")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            
            includeEstimatedCostsButton.setAttributedTitle(attributeString, for: .normal)
        } else {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Include estimated costs")
            includeEstimatedCostsButton.setAttributedTitle(attributeString, for: .normal)
        }
    }
}
