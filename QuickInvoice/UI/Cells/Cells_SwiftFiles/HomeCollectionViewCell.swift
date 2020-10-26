//
//  HomeCollectionViewCell.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 10/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 10
        
        self.contentView.layer.masksToBounds = true
        self.clipsToBounds = false
        
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2.0)
        self.layer.shadowRadius = 2.5
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
    
    func updateShadow() {
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
}

