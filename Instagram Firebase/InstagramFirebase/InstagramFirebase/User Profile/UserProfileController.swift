//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/8/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout , UserProfileHeaderDelegate {
    
    
    var isGridView = true
    
    func didChangeToListView() {
        //print("changing to list view from controller")
        isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        //print("changing to grid view from controller")
        isGridView = true
        collectionView?.reloadData()
    }
    

    
    let cellId = "cellId"
    var userId : String?
    let homePostCellId = "homePostCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "User Profile"
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        fetchUser()
        setupLogoutButton()
       // fetchOrderedPosts()
    }
    var isFinishedPaging = false
    var posts = [Post]()

    fileprivate func paginatePosts(){
        print("paginating posts")
        guard let user = self.user else { return }
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid).child("userPosts")
        let limit = 3
        //basically since we are removing the first post in every iteration we get only limit-1 posts after the first fetch
        //var query = ref.queryOrderedByKey()
        
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0{
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: UInt(limit)).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            if allObjects.count < limit {
                self.isFinishedPaging = true
                print("done paging")
            }
            if self.posts.count > 0 && allObjects.count > 0{
                allObjects.removeFirst()
            }
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
                print(snapshot.key)
            })
            
//            self.posts.forEach({ (post) in
//                print(post.id ?? "")
//            })
            
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("failed to paginate for posts:",error)
        }
        
    }
    
    fileprivate func fetchOrderedPosts(){
        
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid).child("userPosts")
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let user = self.user else { return }
            let key = snapshot.key
            guard let dictionary = snapshot.value as? [String:Any] else {  return }
            var post = Post(user: user, dictionary: dictionary)
            post.id = key
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                if let value = snapshot.value as? Int, value == 1{
                    post.hasLiked = true
                }else {
                    post.hasLiked = false
                }
                
                self.posts.insert(post, at: 0)
                //self.posts.append(post)
                self.collectionView?.reloadData()
               
            }, withCancel: { (err) in
                print("couldnt fetch like data:",err)
                
            })
        }) { (err) in
            print("failed to fetch posts:",err)
        }

        
    }
    fileprivate func setupLogoutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
        //navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    }
    
    @objc func handleLogout(){
        print("logging out..")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navigationController = UINavigationController(rootViewController: loginController)
                self.present(navigationController, animated: true, completion: nil)
                
            }catch let signOutErr{
                print("Failed to sign out:", signOutErr)
            }
        }))
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("header cell returned")
         let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("header size returned")
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGridView {
            if (indexPath.item == self.posts.count - 1) && !isFinishedPaging {
                self.paginatePosts()
            }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
        cell.post = posts[indexPath.item]
        return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
        let width = (view.frame.width - 2)/3
        return CGSize(width:  width, height: width)
        }else {
            
            var height: CGFloat = 40 + 8 + 8
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    var user : User?
    
    
    fileprivate func fetchUser(){
        print("data fetching")
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            //self.fetchOrderedPosts()
            self.paginatePosts()
        }
    }
    
    
}

