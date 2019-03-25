//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/9/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController : UIViewController {
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    var selectedImage : UIImage?{
        didSet{
            self.imageView.image = selectedImage
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
   fileprivate func setupImageAndTextViews(){
    
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
    
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 100)
    
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingLeft: 8, paddingBottom: -8, paddingRight: 0, paddingTop: 8, width: 84, height: 0)
    
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0)
    
    
    }
    
    @objc func handleShare(){
        
        guard let caption = textView.text, caption.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                 self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("could not upload photo:",err)
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("succesfully uploaded message", imageUrl)
            
            self.saveToDatabaseWithImageUrl(url: imageUrl)
        }
    
    }
    
    fileprivate func saveToDatabaseWithImageUrl(url: String){
        
        guard let image = self.selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid).child("userPosts")
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl":url, "caption":caption,"imageWidth":image.size.width, "imageHeight":image.size.height, "creationDate":Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("failed to save post to db",err)
                return
            }
            
            print("successfully saved post info to db")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
