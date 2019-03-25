//
//  FirebaseUtils.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/12/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User)->()){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String:Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (err) in
            print("failed to fetch user data:",err)
        }
    }
}
