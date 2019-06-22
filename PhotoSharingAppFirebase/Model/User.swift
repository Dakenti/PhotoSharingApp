//
//  User.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 3/26/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import Foundation

struct User {
    
    let username: String?
    let profileImageUrl: String?
    let uid: String
    
    init(uid: String, dictionary: [String : Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
    
}
