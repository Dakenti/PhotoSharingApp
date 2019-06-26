//
//  UserProfileController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 3/25/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController {
    
    let cellHeaderId = "cellHeaderId"
    let cellId = "cellId"
    let homePostCellId = "homePostCell"
    
    var user: User?
    var posts = [Post]()
    var userId: String?
    
    var isFinishedPaginating = false
    var isGridView = true
    
    let refreshControl: UIRefreshControl = {
        let rf = UIRefreshControl()
        rf.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
                
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellHeaderId)
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        collectionView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: NSNotification.Name(rawValue: "UpdateFeed"), object: nil)
        
        setupLogOutButton()
        
        fetchUser()
    }
}

// MARK: Fetching User info

extension UserProfileController {
    
    fileprivate func fetchUser() {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? " ")
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.paginatePosts()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func setupLogOutButton() {
        if let currentLoggedInUser = Auth.auth().currentUser?.uid, currentLoggedInUser == userId {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
        }
    }
    
    @objc func handleLogOut() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do{
                try Auth.auth().signOut()
            } catch let alertError {
                print("Error in logging out", alertError)
            }
        
            let loginController = LoginController()
            let navController = UINavigationController(rootViewController: loginController)
            self.present(navController, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func fetchPosts() {
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? " ")
        
        let dbRef = Database.database().reference().child("posts").child(uid)
        dbRef.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let post = Post(user: self.user!, dictionary: dictionary)
            self.posts.append(post)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }) { (error) in
            print("Error in fetching post's image", error)
        }
    }
    
    fileprivate func paginatePosts() {
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
        guard let user = user else { return }
        let ref = Database.database().reference().child("posts").child(userId ?? currentLoggedUserId)
        
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaginating = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
                
            })
            
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Failed to implement pagination", err)
        }
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc fileprivate func handleRefresh() {
        print("Handling refresh..")
        posts.removeAll()
        collectionView.reloadData()
        fetchPosts()
    }
}

// MARK: Setting up Collection view properties

extension UserProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.posts.count - 1 && !isFinishedPaginating {
            print("Paginating for posts")
            paginatePosts()
        }
        
        if isGridView {
            let userProfileCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            userProfileCell.post = posts[indexPath.item]
            return userProfileCell
        } else {
            let homePostCell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            homePostCell.post = posts[indexPath.item]
            return homePostCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            
            return CGSize(width: width, height: width)
        } else {
            let width = view.frame.width // width
            var height: CGFloat = 40 + 8 + 8 // userProfileImageView, usernameLabel, optionButton
            height += width // photoImageView
            height += 44 // actionButtons
            height += 70 // captionLabel
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}

// MARK: Setting up Supplementary View's configurations

extension UserProfileController: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cellHeaderId, for: indexPath) as! UserProfileHeader
        
        header.user = user
        
        header.delegate = self
        
        header.userId = userId

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

extension UserProfileController: UserProfileHeaderDelegate {
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }

}





