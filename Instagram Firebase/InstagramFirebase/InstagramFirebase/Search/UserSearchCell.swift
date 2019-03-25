//
//  UserSearchCell.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/12/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

class UserSearchCell : UICollectionViewCell {
    let userProfileImageView : CustomImageView = {
        let civ = CustomImageView()
        civ.contentMode = .scaleAspectFill
        civ.clipsToBounds = true
        civ.layer.cornerRadius = 25.0
        return civ
    }()
    
    let userName : UILabel = {
        let label = UILabel()
        label.text = "sample text"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        //label.backgroundColor  = UIColor.yellow
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(userProfileImageView)
        userProfileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 50, height: 50)
        userProfileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(userName)
        userName.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor , paddingLeft: 8 , paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: userName.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0.5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
