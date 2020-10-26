//
//  EditInformationViewController.swift
//  QuickInvoice
//
//  Created by Alex Drewno on 8/19/20.
//  Copyright © 2020 Alex Drewno. All rights reserved.
//

import Foundation
import UIKit

class EditInformationViewController: UIViewController {
    var curUserInformation: UserInformation!
    
    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var restofAddressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var telephoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @IBAction func saveCurUserInfo(_ sender: Any) {
        let alert = UIAlertController(title: "Success!", message: "Your changes have been saved", preferredStyle: UIAlertController.Style.alert)
         
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        postCurUserInformation(email: emailTextField.text!,
                              name: companyNameTextField.text!,
                              restofAddress: restofAddressTextField.text!,
                              streetAddress: streetAddressTextField.text!,
                              telephone: telephoneTextField.text!)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        postCurUserInformation(email: emailTextField.text!,
                              name: companyNameTextField.text!,
                              restofAddress: restofAddressTextField.text!,
                              streetAddress: streetAddressTextField.text!,
                              telephone: telephoneTextField.text!)
        
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Setup
extension EditInformationViewController {
    func setup() {
        curUserInformation = fetchCurUserInformation()
        
        setupLabels()
    }
    
    func setupLabels() {
        if let curUserInfo = curUserInformation {
            companyNameTextField.text = curUserInfo.name
            streetAddressTextField.text = curUserInfo.streetAddress
            restofAddressTextField.text = curUserInfo.restofAddress
            emailTextField.text = curUserInfo.email
            telephoneTextField.text = curUserInfo.telephone
        } else {
            companyNameTextField.text = ""
            streetAddressTextField.text = ""
            restofAddressTextField.text = ""
            emailTextField.text = ""
            telephoneTextField.text = ""
        }
    }
}


