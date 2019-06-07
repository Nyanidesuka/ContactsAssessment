//
//  ContactDetailViewController.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import CloudKit

class ContactDetailViewController: UIViewController {

    //landing pad 🚁
    var contact: Contact?{
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        //unwrap the text fields' texts
        let phoneCharacterset = "()-1234567890"
        guard let contactName = nameTextField.text,
        let contactPhone = phoneNumberTextField.text,
            let contactEmail = emailTextField.text else {return}
        if contactName == ""{
            //if the name is blank, we should notify the user using a simple alert. AMke the alert
            let blankNameAlert = UIAlertController(title: "Hold up bub", message: "The Name field must be filled out.", preferredStyle: .alert)
            //make an action to close it
            let closeAction = UIAlertAction(title: "Got it", style: .destructive, handler: nil)
            //add the action
            blankNameAlert.addAction(closeAction)
            //present the alert
            self.present(blankNameAlert, animated: true, completion: nil)
            return
        } else if contactPhone.contains(where: {!phoneCharacterset.contains($0)}) && contactPhone != ""{
            //if the phone number contains anything besides a letter, number, parenthesis, or dash, and it's not just blank cuz blank is allowed
            let phoneCharAlert = UIAlertController(title: "Hold up bub", message: "The phone number should only contain numbers, (, ), and -", preferredStyle: .alert)
            //make an action to close it
            let closeAction = UIAlertAction(title: "Got it", style: .destructive, handler: nil)
            //add the action
            phoneCharAlert.addAction(closeAction)
            //present the alert
            self.present(phoneCharAlert, animated: true, completion: nil)
            return
            
        }else {
            //otherwise we hve everything we need to make or update a contact. Let's see which of the two we're doing.
            if let contact = contact{
                //this should double as unwrapping the contact and checking that it's there. If it's there we need to update.
                ContactController.shared.updateContact(contact: contact, name: contactName, phoneNumber: contactPhone, email: contactEmail) { (success) in
                    //when that's done we wanna pop the VC
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                //so if we get here it should mean there was no contact; it's nil. So we gotta make a new contact.
                //then make a new contact.
                ContactController.shared.createContact(name: contactName, phoneNumber: contactPhone, email: contactEmail) { (success) in
                    //then when we're done, pop the VC
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func updateViews(){
        guard let contact = contact else {return}
        self.nameTextField.text = contact.name
        self.phoneNumberTextField.text = contact.phoneNumber
        self.emailTextField.text = contact.email
        self.navigationItem.title = contact.name
    }
}
