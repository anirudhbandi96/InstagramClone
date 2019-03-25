//
//  Post.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/11/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

struct Post{
    
    var id: String?
    
    let imageUrl : String
    let user: User
    let caption :String
    let creationDate: Date
    
    var hasLiked: Bool = false
    
    init(user: User, dictionary: [String:Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.user = user
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
    }
}
