//
//  SharePopoverViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 10/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class SharePopoverViewController: UIViewController {
    var parentVC: PDFPreviewViewController!
    
    @IBAction func sharePDFAction(_ sender: Any) {
        self.dismiss(animated: true) {
            self.parentVC.sharePDF()
        }
    }
    
    @IBAction func shareCSVAction(_ sender: Any) {
        self.dismiss(animated: true) {
            self.parentVC.shareCSV()
        }
    }
}
