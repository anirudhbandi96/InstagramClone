//
//  CommentCell.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/14/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

class CommentCell : UICollectionViewCell {
    
    var comment : Comment? {
        didSet{
            guard let comment = self.comment else { return }
            let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(string: comment.user.username, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)]))
            attributedText.append(NSAttributedString(string: " \(comment.text)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        //iv.backgroundColor = UIColor.red
        return iv
    }()
    let textView : UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isEditable = false
        textView.isScrollEnabled = false
        //label.backgroundColor = UIColor.lightGray
        return textView
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        //self.backgroundColor = UIColor.green
        
        addSubview(textView)
        addSubview(profileImageView)
        
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 4, paddingBottom: -4, paddingRight: -4, paddingTop: 4, width: 0, height: 0)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, paddingTop: 8, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 20.0
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
