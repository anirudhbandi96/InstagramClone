//
//  PhotoSelectorHeaderCell.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/9/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

class PhotoSelectionHeaderCell : UICollectionViewCell {
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0)
    }
    
    func setHeaderImage(image: UIImage?) {
        self.imageView.image = image
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
