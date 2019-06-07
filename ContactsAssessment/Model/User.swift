//
//  User.swift
//  ContactsAssessment
//
//  Created by Haley Jones on 6/7/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CloudKit

class User{
    //all we really need it to hold is an ID and a reference to a User record
    let appleUserReference: CKRecord.Reference
    var recordID: CKRecord.ID
    
    init(appleUserReference: CKRecord.Reference, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.appleUserReference = appleUserReference
        self.recordID = recordID
    }
    //be able to make a User from a record
    convenience init?(record: CKRecord){
        guard let userReference = record[UserKeys.userKey] as? CKRecord.Reference else {return nil}
        self.init(appleUserReference: userReference, recordID: record.recordID)
    }
    
}
//anti-typo aparatus
struct UserKeys{
    static let typeKey = "User"
    static let userKey = "appleUserReference"
}

//be able to make a record from User
extension CKRecord{
    convenience init(user: User){
        self.init(recordType: UserKeys.typeKey, recordID: user.recordID)
        setValue(user.appleUserReference, forKey: UserKeys.userKey)
    }
}
