//
//  CommentInputTextVIew.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/16/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    fileprivate let placeholderLabel : UILabel = {
        let label = UILabel()
        label.text = "enter comment"
        label.textColor = UIColor.lightGray
        return label
        
    }()
    
     func removePlaceholderText(){
        placeholderLabel.text = ""
    }
     func addPlaceholderText(){
        placeholderLabel.text = "enter comment"
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, paddingTop: 8, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
