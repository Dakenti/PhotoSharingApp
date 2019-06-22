//
//  UserSearchController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/6/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController {
    
    let cellId = "CellId"
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search for a User"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        sb.delegate = self
        
        return sb
    }()
    
    var users = [User]()
    var filtredUsers = [User]()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationBarSearchArea()
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
}

extension UserSearchController {
    
    fileprivate func setupNavigationBarSearchArea() {
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, right: navBar?.rightAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, paddingTop: 0, paddingRight: -8, paddingLeft: 8, paddingBottom: -4, width: 0, height: 0)
    }
    
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String:Any] else { return}
            dictionaries.forEach({ (key, value) in
                // to exclude the current user from being shown in Search List
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as? [String:Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            })
            
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.username?.compare(u2.username!) == .orderedAscending
            })
            
            self.filtredUsers = self.users
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }) { (err) in
            print("err, in fetching users for search queries", err)
        }
    }
    
}

extension UserSearchController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        cell.user = filtredUsers[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = users[indexPath.item].uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
}

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
}

extension UserSearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filtredUsers = users
        } else {
            self.filtredUsers = users.filter({ (user) -> Bool in
                return (user.username?.lowercased().contains(searchText.lowercased()))!
            })
        }
        self.collectionView.reloadData()
    }
    
}




