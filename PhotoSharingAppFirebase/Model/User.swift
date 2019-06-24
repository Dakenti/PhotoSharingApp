//
//  User.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 3/26/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import Foundation

struct User {
    let email: String?
    let username: String?
    let profileImageUrl: String?
    var uid: String
    
    init(uid: String, dictionary: [String : Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? "" 
        self.uid = uid
    }
    
}
