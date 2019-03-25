//
//  HomePostCell.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/11/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase
protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}


class HomePostCell: UICollectionViewCell {
    
    
    var delegate : HomePostCellDelegate?
    
    var post: Post? {
        didSet{
            //print(post?.imageUrl ?? "")
            guard let postImageUrl = post?.imageUrl else { return }
            likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal):#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            photoImageView.loadImage(urlString: postImageUrl)
            userNameLabel.text = post?.user.username
            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            userProfileImageView.loadImage(urlString: profileImageUrl)
            getNumberOfLikes()
            setupAttributedCaption()
        }
    }
    fileprivate func setupAttributedCaption(){
        guard let post = post else { return }
        let attributedtext = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedtext.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
        attributedtext.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 4)]))
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedtext.append(NSAttributedString(string:  timeAgoDisplay, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13),NSAttributedStringKey.foregroundColor : UIColor.gray]))
        captionLabel.attributedText = attributedtext
    }
    let userProfileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let photoImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let optionsButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    lazy var likeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment(){
        print("trying to show comments")
        guard let post = self.post else { return }
        delegate?.didTapComment(post: post)
        
    }
    
    @objc func handleLike(){
        print("handling like within the cell..")
        delegate?.didLike(for: self)
    }
    
    let sendMessageButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let bookmarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let captionLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let numberOfLikeslabel: UILabel = {
        let label  = UILabel()
        label.text = "loading.."
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        addSubview(userProfileImageView)
        addSubview(optionsButton)
        addSubview(userNameLabel)
        
        userProfileImageView.layer.cornerRadius = 20.0
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 8, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, paddingTop: 8, width: 40, height: 40)
        userNameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 0)
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 40, height: 0)
        setupActionButtons()
        addSubview(captionLabel)
        captionLabel.anchor(top: numberOfLikeslabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, paddingTop: 0, width: 0, height: 0)
        
        setupDoubleTapGestureRecognizer()
        
        
    }
    
    fileprivate func setupDoubleTapGestureRecognizer(){
        photoImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(gestureRecognizer)
    }
    @objc func handleDoubleTap(){
        print("handling double Tap")
        heartAnimation()
        delegate?.didLike(for: self)
    }
    fileprivate func heartAnimation(){
        
        let heartView = UIImageView()
        heartView.image = #imageLiteral(resourceName: "like_selected")
        heartView.frame = CGRect(x: photoImageView.frame.width/2 - 20, y: photoImageView.frame.width/2 - 20, width: 40, height: 40)
        photoImageView.addSubview(heartView)
        
        heartView.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            heartView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        }, completion: { (completed) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                heartView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                heartView.alpha = 0
            }, completion:{ (_) in
                heartView.removeFromSuperview()
            })
        })
        
    }
    fileprivate func setupActionButtons(){
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(numberOfLikeslabel)
        addSubview(bookmarkButton)
        
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 120, height: 50)
        numberOfLikeslabel.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 0, height: 20)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, paddingTop: 0, width: 40, height: 50)
        
    }
    fileprivate func getNumberOfLikes(){
        guard let id = self.post?.id else { return }
        Database.database().reference().child("likes").child(id).child("likes_count").observe(.value) { (snapshot) in
            if let num = snapshot.value as? Int {
                self.numberOfLikeslabel.text = "\(num) likes"
            } else {
                self.numberOfLikeslabel.text = "0  likes"
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
