//
//  CustomImageVIew.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/11/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastUrlToLoadImage : String?
    
    func loadImage(urlString:String){
        
        self.image = nil
        self.lastUrlToLoadImage = urlString
        
        if let cachedImage = imageCache[urlString]  {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("failed to fetch post image:",error)
                return
            }
            
            if url.absoluteString != self.lastUrlToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            let image = UIImage(data: imageData)
            imageCache[url.absoluteString] = image
            DispatchQueue.main.async {
                self.image = image
            }
            
            
            }.resume()
    }
        
    }

