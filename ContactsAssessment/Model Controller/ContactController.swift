//
//  ContactController.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//
//This one i'm also nervous about but 6% less so than the user handling.
import Foundation
import CloudKit

class ContactController{
    //needs a singleton
    static let shared = ContactController()
    private init(){} //flex on 'em
    //i want to make a reference to the database from the UserController just to  type less later.
    let privateDB = UserController.shared.privateDB
    //and now we need the source of truth
    var contacts: [Contact] = []
    
    //CRUD Functions
    //definitely need to create. Just has to take in name, number, and email.
    func createContact(name: String, phoneNumber: String, email: String, completion: @escaping (Bool) -> Void){
        //first off, we should have a current user at this point. So we're gonna grab its ID, so we can make a reference to the user and store it in the contact. Back referencing. Super useful for pulling a user's contacts later on.
        guard let userRecordID = UserController.shared.currentUser?.recordID else {completion(false); print("couldn't get the ID of the current user"); return}
        //make that reference
        let userReference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
        //and that's the last new value we need in order to create this new contact.
        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email, userReference: userReference)
        //Welcome our new contact to the app and make a reference for it
        let contactRecord = CKRecord(contact: newContact)
        //and save it to the database
        privateDB.save(contactRecord) { (record, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(false);
                return
            }
            //unwrap the record we got back
            guard let record = record else {print("The record in completion for \(#function) is nil."); completion(false); return}
            //add the contact to the source of truth
            guard let contact = Contact(record: record) else {completion(false); return}
            ContactController.shared.contacts.append(contact)
            //ALWAYS complete
            completion(true)
        }
    }
    
    //definitely gotta fetch. We only want contacts for our current icloud user. So we'll take that in. Add a completion because this is a network boi
    func fetchContacts(forUser user: User, completion: @escaping (Bool) -> Void){
        
        //first up. We need a reference to our user. Good thing we took the user in as a parameter.
        let userReference = CKRecord.Reference(record: CKRecord(user: user), action: .deleteSelf)
        //Next up we have to start buildin our query, starting with a predicate which compares the userReference of a contact to make sure it matches the one for our current user.
        let predicate = NSPredicate(format: "%K == %@", ContactKeys.userKey, userReference)
        let query = CKQuery(recordType: ContactKeys.typeKey, predicate: predicate)
        //now we'll run that query.
        privateDB.perform(query, inZoneWith: .default) { (records, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(false)
                return
            }
            //unwrap the records array
            guard let records = records else {completion(false); return}
            //Map over the array to turn it from an array of record into an array of contact. Map is neat.
            let contacts = records.compactMap({return Contact(record: $0)})
            //now that we have a bunch of contacts, stick them in the source of truth
            ContactController.shared.contacts = contacts
            //and complete triumphant
            completion(true)
        }
    }
    
    //definitely need to update.
    func updateContact(contact: Contact, name: String, phoneNumber: String, email: String, completion: @escaping(Bool) -> Void){
        //update the values in the contact object
        contact.name = name
        contact.email = email
        contact.phoneNumber = phoneNumber
        //create a record from that newly updated contact
        let contactRecord = CKRecord(contact: contact)
        //create a ModifyRecordsOperation. Used by cloudkit to modify records, pretty self-explanatory name
        //pass it the record we want to modify, which is just the one contact. We dont wanna delete anything.
        let operation = CKModifyRecordsOperation(recordsToSave: [contactRecord], recordIDsToDelete: nil)
        //Tell it to only bother saving keys that had their values changed
        operation.savePolicy = .changedKeys
        //But like, make it a high priority.
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        operation.completionBlock = {
            //when it finished doing the operation, call this function's completion with True.
            completion(true)
        }
        //add the operation to the database so it'll run it.
        privateDB.add(operation)
    }
    
    //will do delete if i have time -- Update, i have time!
    func deleteContact(contact: Contact, completion: @escaping (Bool) -> Void){
        //actually pretty easy, our contacts already store their record ID, we can use that to target and delete them.
        privateDB.delete(withRecordID: contact.recordID) { (recordID, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(false)
                return
            }
            //and now i just need to delete locally. Bet u 1 cheeto i can do this without equatable
            guard let targetIndex = ContactController.shared.contacts.firstIndex(where: {$0.recordID == contact.recordID}) else {completion(false); return}
            ContactController.shared.contacts.remove(at: targetIndex)
            completion(true)
        }
    }
}
