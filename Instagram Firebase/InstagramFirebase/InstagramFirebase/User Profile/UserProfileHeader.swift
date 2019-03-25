//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/8/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate{
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader : UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()
    
    lazy var gridButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
         button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    @objc func handleChangeToGridView(){
        print("changing to grid view")
        gridButton.tintColor = UIColor.mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    lazy var listButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    @objc func handleChangeToListView(){
        print("changing to list view")
        listButton.tintColor = UIColor.mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    let bookmarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.attributedText = self.attributedTextHelperFun(text: "-", label: "posts")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate func attributedTextHelperFun(text: String, label: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text + "\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label , attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
        return attributedText
    }
    
   lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.attributedText = attributedTextHelperFun(text: "-", label: "followers")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = attributedTextHelperFun(text: "-", label: "following")
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var editProfileFollowButton : UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3.0
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, paddingTop: 12, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.layer.masksToBounds = true
        
        setupBottomToolbar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, paddingTop: 4, width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 2, width: 0, height: 34)
    }
    
    fileprivate func setupBottomToolbar(){
        
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0.5)
        
       
    }
    
    var user : User? {
        didSet{
            guard let profileImageUrl = user?.profileImageUrl else { return }
            self.profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
            setupFollowingLabel()
            setupFollowersLabel()
            setupPostsLabel()
        }
    }
    fileprivate func setupFollowingLabel(){
        guard let userId = user?.uid else { return }
        Database.database().reference().child("following").child(userId).child("following_count").observe(.value) { (snapshot) in
                print("following number")
                if let num = snapshot.value as? Int {
                    self.followingLabel.attributedText = self.attributedTextHelperFun(text: "\(num)", label: "following")
                }else{
                    self.followingLabel.attributedText = self.attributedTextHelperFun(text: "\(0)", label: "following")
                }
            }
        }
    fileprivate func setupPostsLabel(){
        guard let userId = user?.uid else { return }
        Database.database().reference().child("posts").child(userId).child("post_count").observe(.value) { (snapshot) in
            print("posts count")
            if let num = snapshot.value as? Int {
                self.postsLabel.attributedText = self.attributedTextHelperFun(text: "\(num)", label: "posts")
            }else{
                self.postsLabel.attributedText = self.attributedTextHelperFun(text: "\(0)", label: "posts")
            }
        }
    }
    fileprivate func setupFollowersLabel(){
        guard let userId = user?.uid else { return }
        Database.database().reference().child("followedBy").child(userId).child("follower_count").observe(.value) { (snapshot) in
            print("followers number")
            if let num = snapshot.value as? Int {
                self.followersLabel.attributedText = self.attributedTextHelperFun(text: "\(num)", label: "followers")
            }else{
                self.followersLabel.attributedText = self.attributedTextHelperFun(text: "\(0)", label: "followers")
            }
        }
    }
    fileprivate func setupEditFollowButton(){
        
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        if currentLoggedInUser != userId {
            //check if following
            
            Database.database().reference().child("following").child(currentLoggedInUser).child("usersFollowing").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1{
                    self.setupUnfollowStyle()
                } else {
                    self.setupFollowStyle()
                }
            }) { (err) in
                print(err)
            }
   
            
        }else {
            //Edit profile
        }
        
        
    }
    fileprivate func setupUnfollowStyle() {
        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.white
        self.editProfileFollowButton.setTitleColor(UIColor.black, for: .normal)
    }
    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor  = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.setTitleColor(UIColor.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    @objc func handleEditProfileOrFollow(){
        print("inside handle func")
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = self.user?.uid else {  return }
        
        if editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            //edit profile logic
            print("performing edit profile")
            
        } else if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            //unfollowing logic
            Database.database().reference().child("following").child(currentLoggedInUserId).child("usersFollowing").child(userId).removeValue { (err, ref) in
                    if let err = err {
                        print("failed to unfollow user:",err)
                        return
                    }
            Database.database().reference().child("followedBy").child(userId).child("followers").child(currentLoggedInUserId).removeValue(completionBlock: { (err, ref) in
                    if let err = err {
                        print("failed to remove the user from followedBy node:",err)
                        return
                    }
                })
                
                print("succesfully unfollowed user:",userId)
                
                self.setupFollowStyle()
            }
        
        }else {
            //following logic
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId).child("usersFollowing")
            let values = [userId:1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("failed to follow user:",err)
                    return
                }
                Database.database().reference().child("followedBy").child(userId).child("followers").updateChildValues([currentLoggedInUserId:1], withCompletionBlock: { (err, ref) in
                    print("failed to add current user to followers node of the following user")
                })
                print("successfully followed the user:",self.user?.username ?? "")
                
                self.setupUnfollowStyle()
            }
        
        }
        
    }
    
    
    
    fileprivate func setupUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addSubview(stackView)
        
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingLeft: 12, paddingBottom: 0, paddingRight: -12, paddingTop: 12, width: 0, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
