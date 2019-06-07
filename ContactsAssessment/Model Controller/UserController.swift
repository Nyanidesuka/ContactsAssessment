//
//  UserController.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//
//Doing this one first because i'm more nervous about it
import Foundation
import CloudKit

class UserController{
    //this guy should def be a singleton
    static let shared = UserController()
    private init(){} //flex move, make the only initializer private
    
    //the database, a base for data. Private because contacts seem like a private thing
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //and a way to keep track of what user we're dealing with.
    var currentUser: User?
    
    //CRUD functions. We need to be able to create a new user if one doesn't exist for this icloud account. We also need to be able to fetch the user if one does exist. We're not allowing deleting users.
    //all this needs is a completion; the user won't be passing in anything
    func createUser(completion: @escaping (Bool) -> Void){
        //first thing we have to do is have cloudkit retch the recordID for the current icloud user.
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error{ //handle the error
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(false)
                return
            }
            //now that we know there wasn't an error we can do stuff with the ID we fetched.
            guard let userID = recordID else {completion(false); return}//always complete
            //now that we have thta ID we can use it to find a reference to the user record.
            let appleUserReference = CKRecord.Reference(recordID: userID, action: .deleteSelf)//deleteSelf makes sure if this record is deleted, anything dependant on it also deleted.
            //now that we have a reference we can create a new User with it.
            let newUser = User(appleUserReference: appleUserReference)
            //And now that we have a user, we can make that user into a record so that it can be saved ot icloud.
            let userRecord = CKRecord(user: newUser)
            //save it to icloud
            self.privateDB.save(userRecord, completionHandler: { (record, error) in
                if let error = error{
                    print("there was an error in \(#function); \(error.localizedDescription)")
                    completion(false)
                    return
                }
                //finally we're done making the user. Assign it as the curent user and complete true.
                self.currentUser = newUser
                completion(true)
            })
        }
    }
    //this function will double as checking if the user record exists already, and assigning it if it does.
    func fetchUser(completion: @escaping (Bool) -> Void){
        print("fetch user fired")
        //again we start with the same fetch
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error{
                print("there was an error in \(#function); \(error.localizedDescription)")
                completion(false)
                return
            }
            print("got user record ID")
            //unwrap what we got back
            guard let userID = recordID else {completion(false); return}
            //make  reference to the record
            let appleUserReference = CKRecord.Reference(recordID: userID, action: .deleteSelf)
            //we're gonna start building a query. First thing we need is a predicate.
            let predicate = NSPredicate(format: "%K == %@", UserKeys.userKey, appleUserReference)
            let query = CKQuery(recordType: UserKeys.typeKey, predicate: predicate)
            //now we can have the query we can run it
            self.privateDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                print("starting contact fetch")
                if let error = error{
                    print("o no there was an error in \(#function); \(error.localizedDescription)")
                    completion(false)
                    return
                }
                //the query returns an awway so we're gonna do some steps to unwrap the array, make sure its not empty, and grab the first thing in it.
                guard let records = records,
                    records.count != 0,
                    let userRecord = records.first else {completion(false); return}
                //now we know we have a Record of a user, so we can make a user from it.
                let currentUser = User(record: userRecord)
                self.currentUser = currentUser
                //and after all that, complete with true
                completion(true)
            })
        }
    }
}
