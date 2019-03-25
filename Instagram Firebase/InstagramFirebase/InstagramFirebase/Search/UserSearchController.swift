//
//  UserSearchController.swift
//  InstagramFirebase
//
//  Created by Anirudh Bandi on 4/12/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase


class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    let cellId = "cellId"
    lazy var  searchBar : UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "enter username"
        sb.barTintColor = UIColor.gray
        sb.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 220, green: 220, blue: 220)
        return sb
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print(searchText)
        if !searchText.isEmpty {
        self.filteredUsers = self.users.filter { (user) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        
        }
        }else {
            self.filteredUsers = self.users
        }
        
        collectionView?.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, paddingTop: 0, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        fetchUsers()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        searchBar.isHidden = false
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = filteredUsers[indexPath.item]
        print(user.username)
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
  
    }
    
    var filteredUsers = [User]()
    var users = [User]()
    
    fileprivate func fetchUsers(){
        
        print("fetching users")
        
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
           // print(snapshot.value ?? "")
            guard let dictionaries = snapshot.value as? [String:Any] else { return }
            dictionaries.forEach({ (key,value) in
               // print(key,value)
                
                guard let userDictionary = value as? [String:Any] else { return }
                guard let currentUid = Auth.auth().currentUser?.uid else { return }
                if key ==  currentUid {
                    print("omiteed myself from the users list")
                    return
                }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
                print(user.uid,user.username)
                
                
            })
            self.users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            self.filteredUsers  = self.users
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("failed to fetch users for search")
        }
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.userProfileImageView.loadImage(urlString: filteredUsers[indexPath.item].profileImageUrl)
        cell.userName.text = filteredUsers[indexPath.item].username
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}


