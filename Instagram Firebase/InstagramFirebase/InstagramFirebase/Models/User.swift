//
//  User.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/12/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import Foundation

struct User{
    let uid  :String
    let username : String
    let profileImageUrl : String
    
    init(uid: String, dictionary : [String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
}
