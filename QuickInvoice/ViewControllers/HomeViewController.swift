//
//  HomeViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/18/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    final var homeActionLabels = ["Create a new invoice",
                                  "Edit information",
                                  "Manage clients",
                                  "View saved items",
                                  "View previous invoices",
                                  "Settings"]
    
    final var imageStrings = ["newInvoiceImage",
                              "curUserImage",
                              "clientsImage",
                              "viewSavedItemsImage",
                              "previousInvoicesImage",
                              "settingsImage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

extension HomeViewController {
    func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.frame.width/2-17 , height: collectionView.frame.width/2-17)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
        
        let nib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "homeCollectionViewCell")
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeActionLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        
        cell.actionLabel.text = homeActionLabels[indexPath.row]
        cell.imageIcon.image = UIImage(named: imageStrings[indexPath.row]) ?? UIImage()
        cell.updateShadow()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newInvoiceVC")
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "CurUserInformation", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "editInfoVC")
            vc.modalPresentationStyle = .popover
            
            self.present(vc, animated: true)
        case 2:
            let storyboard = UIStoryboard(name: "Clients", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "clientsVC")
            vc.modalPresentationStyle = .popover
            
            self.present(vc, animated: true)
        case 3:
            let storyboard = UIStoryboard(name: "Items", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "itemsVC")
            vc.modalPresentationStyle = .popover
            
            self.present(vc, animated: true)
        case 4:
            let storyboard = UIStoryboard(name: "PreviousInvoices", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "previousInvoicesVC")
            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: true)
        case 5:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "settingsVC")
            vc.modalPresentationStyle = .popover
            
            self.present(vc, animated: true)
        default:
            print("Could not find indexpath")
        }
    }
}






