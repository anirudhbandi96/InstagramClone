//
//  UserProfilePhotoCell.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/11/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post : Post?{
        didSet{
            
            guard let imageUrl = post?.imageUrl else { return }
            self.imageView.loadImage(urlString: imageUrl)
           
    }
    }
    
    let imageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
