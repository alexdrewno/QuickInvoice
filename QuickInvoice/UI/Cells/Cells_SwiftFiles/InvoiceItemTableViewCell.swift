//
//  InvoiceItemTableViewCell.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/21/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class InvoiceItemTableViewCell: UITableViewCell {
    @IBOutlet weak var estimatedQuantityLabel: UILabel!
    @IBOutlet weak var actualQuantityLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
}
