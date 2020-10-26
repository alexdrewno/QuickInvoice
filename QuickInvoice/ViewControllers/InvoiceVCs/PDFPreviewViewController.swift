//
//  PDFPreviewViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import PDFKit

// MARK: - Properties
class PDFPreviewViewController: UIViewController {
    var pdfCreator: PDFCreator!
    var csvCreator: CSVCreator!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfCollectionView: UICollectionView!
    var documentStyles: [PDFDocument] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setup()
    }
    
    @IBAction func dismissSelfButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        showShareButtonActionSheet()
    }
}

// MARK: - Setup
extension PDFPreviewViewController {
    func setupCollectionView() {
        pdfCollectionView.delegate = self
        pdfCollectionView.dataSource = self
        
        let nib = UINib(nibName: "PDFStyleCollectionViewCell", bundle: nil)
        pdfCollectionView.register(nib, forCellWithReuseIdentifier: "PDFStyleCollectionViewCell")
    }
    
    func setup() {
        pdfView.document = PDFDocument(data: pdfCreator.classicStylePDF())
        pdfView.autoScales = true
        
        documentStyles.append(PDFDocument(data: pdfCreator.classicStylePDF())!)
        documentStyles.append(PDFDocument(data: pdfCreator.secondStylePDF())!)
        documentStyles.append(PDFDocument(data: pdfCreator.specialStylePDF())!)
        pdfCollectionView.reloadData()

    }
    
    func showShareButtonActionSheet() {
        let alertController = UIAlertController(title: nil, message: "Share as", preferredStyle: .actionSheet)
        
        let csvAction = UIAlertAction(title: "CSV File", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.shareCSV()
        })
        
        let pdfAction = UIAlertAction(title: "PDF File", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.sharePDF()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(csvAction)
        alertController.addAction(pdfAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Collection View Functions
extension PDFPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentStyles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pdfCollectionView.dequeueReusableCell(withReuseIdentifier: "PDFStyleCollectionViewCell", for: indexPath) as! PDFStyleCollectionViewCell
        
        cell.pdfView.isUserInteractionEnabled = false
        cell.pdfView.backgroundColor = .clear
        cell.pdfView.document = documentStyles[indexPath.row]
        cell.pdfView.autoScales = true

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pdfView.document = documentStyles[indexPath.row]
    }
    
}

// MARK: - Popover View Functions
extension PDFPreviewViewController: UIPopoverPresentationControllerDelegate {
    @objc func showPopoverView() {
        if let pvc = self.storyboard?.instantiateViewController(withIdentifier: "sharePVC")
                    as?  SharePopoverViewController {

            pvc.parentVC = self
            pvc.modalPresentationStyle = .popover
            pvc.preferredContentSize = CGSize(width: 200, height: 100)

            let popover = pvc.popoverPresentationController
            popover?.delegate = self as UIPopoverPresentationControllerDelegate
            popover!.sourceView = shareButton

            present(pvc, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

// MARK: - Actions
extension PDFPreviewViewController {
    
    // TODO: - Error checking and alerting user
    // TODO: - Possible Refactoring here
    
    func sharePDF() {
        if let pdfData = pdfView.document?.dataRepresentation() {
            let objectsToShare = [pdfData]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = shareButton

            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func shareCSV() {
        csvCreator.shareInvoiceCSV(sourceVC: self, sourceView: shareButton)
    }
}
