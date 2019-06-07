//
//  Contact.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CloudKit //need that

class Contact{
    //properties, vars because we're allowing editing
    var name: String
    var phoneNumber: String
    var email: String
    var userReference: CKRecord.Reference //so it can know what user it belongs to
    var recordID: CKRecord.ID
    
    //an initializer, we're gonna have to pass in a reference to a User object when we make one of these. We set  default for the ID.
    init(name: String, phoneNumber: String, email: String, userReference: CKRecord.Reference, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.userReference = userReference
        self.recordID = recordID
        self.email = email
        self.phoneNumber = phoneNumber
    }
    
    //we need a way to make one of these out of a record, because cloudkit can't store our custom types.
    convenience init?(record: CKRecord){
        //grab the properties by subscripting the record
        guard let name = record[ContactKeys.nameKey] as? String,
        let phoneNumber = record[ContactKeys.phoneNumberKey] as? String,
        let email = record[ContactKeys.emailKey] as? String,
            let userReference = record[ContactKeys.userKey] as? CKRecord.Reference else {return nil}
        //now that we have all that we can call our designated init.
        self.init(name: name, phoneNumber: phoneNumber, email: email, userReference: userReference, recordID: record.recordID)
    }
    
}

//making keys to avoid spelling mistakes
struct ContactKeys{
    static let typeKey = "Contact"
    static let nameKey = "name"
    static let phoneNumberKey = "phoneNumber"
    static let emailKey = "email"
    static let userKey = "userReference"
}


//and now we need a way to make a record out of a contact
extension CKRecord{
    convenience init(contact: Contact){
        self.init(recordType: ContactKeys.typeKey, recordID: contact.recordID)
        setValue(contact.name, forKey: ContactKeys.nameKey)
        setValue(contact.phoneNumber, forKey: ContactKeys.phoneNumberKey)
        setValue(contact.email, forKey: ContactKeys.emailKey)
        setValue(contact.userReference, forKey: ContactKeys.userKey)
    }
}
