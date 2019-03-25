//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/11/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase



class HomeController: UICollectionViewController,  UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    func didTapComment(post: Post) {
        print("message coming from home controller")
        print("tapped on post:",post.caption)
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = posts[indexPath.item]
        guard let postId = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if !post.hasLiked {
            Database.database().reference().child("likes").child(postId).child("users").updateChildValues([uid: 1]) { (err, ref) in
            if let err = err{
                print("couldnt uplod like data:",err)
            }
            print("post successfully liked")
            
        }
        }else {
            Database.database().reference().child("likes").child(postId).child("users").child(uid).removeValue { (err, ref) in
                if err != nil {
                    print("couldnt unlike post")
                    return
                }
                print("successfullt unliked the post")
            }
        }
        post.hasLiked = !post.hasLiked
        self.posts[indexPath.item] = post
        self.collectionView?.reloadItems(at: [indexPath])
   }

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchAllPosts()
        
    }
    
    @objc func handleUpdateFeed(){
     handleRefresh()
    }
    
    @objc func handleRefresh(){
        
        print("handling refresh")
        posts.removeAll()
        fetchAllPosts()
       
        
    }
    fileprivate func fetchAllPosts(){
        fetchMyPosts()
        fetchFollowingUserPosts()
    }
    var posts = [Post]()
    
    fileprivate func fetchFollowingUserPosts(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(userId).child("usersFollowing").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            dictionary.forEach({ (key,_) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostWithUser(user: user)
                })
            })
        }) { (err) in
            print("failed to get data:",err)
        }
    }
    
    fileprivate func fetchPostWithUser(user: User) {
        
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid).child("userPosts")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String:Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                //print(user.username, post.id)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    //print(snapshot)
                    if let value = snapshot.value as? Int, value == 1{
                        post.hasLiked = true
                    }else {
                        post.hasLiked = false
                    }
                    //print("before reloading:",self.posts.count)
                    self.posts.append(post)
                    self.posts.sort(by: { (post1, post2) -> Bool in
                        return post1.creationDate.compare(post2.creationDate) == .orderedDescending
                        })
                    self.collectionView?.reloadData()
                    //print("collectionView reloaded")
                }, withCancel: { (err) in
                    print("couldnt fetch like data:",err)
                
            })
            })
            
            
        }) { (err) in
            print("failed to fetch posts:",err)
        }
    }
    
    fileprivate func fetchMyPosts(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostWithUser(user: user)
        }
      
        
    }
    

    func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
    }
    
    @objc func handleCamera(){
        print("show camera")
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("numnber of items in section called")
        //print(posts.count)
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 60
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
}
