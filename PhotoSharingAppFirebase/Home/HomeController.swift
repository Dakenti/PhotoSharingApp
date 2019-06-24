//
//  HomeController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/5/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController {
    
    let cellId = "cellId"
    
    let refreshControl: UIRefreshControl = {
        let rf = UIRefreshControl()
        rf.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rf
    }()
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: NSNotification.Name(rawValue: "UpdateFeed"), object: nil)

        setupNavigationBarButtons()
        fetchAllPosts()
    }
    
}

// MARK: Fileprivate functions of Home Controller

extension HomeController {
    
    fileprivate func fetchFollowingUsersPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following user ids:", err)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(currentLoggedUserId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.isLiked = true
                    } else {
                        post.isLiked = false
                    }
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    self.collectionView?.reloadData()
                    
                }, withCancel: { (err) in
                    print("err, in chaning like state",err)
                })
            })
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }

    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        posts.removeAll()
        collectionView.reloadData()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUsersPosts()
    }
    
    fileprivate func setupNavigationBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(hanleCameraPress))
    }
    
    @objc func hanleCameraPress() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
}

// MARK: Collection view set up

extension HomeController: HomePostCellDelegate {
    func sendMessageButtonPressed(to toUser: String) {
        print(toUser)
    }
    
    func sendMessagebuttonPressed(to toUser: String) {
        print(toUser)
        let newMessageController = NewMessageController(style: .plain)
        present(newMessageController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }
    
    func didTapCommentButton(post: Post) {
        let commentController = CommentController(collectionViewLayout: UICollectionViewFlowLayout())
        commentController.post = post
        navigationController?.pushViewController(commentController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var post = posts[indexPath.item]
        guard let postId = post.id else { return }
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
        let values = [currentLoggedUserId : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, ref) in
            if err != nil {
                print("err, in setting up likes", err ?? "")
                return
            }
            post.isLiked = !post.isLiked
            self.posts[indexPath.item] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
}

// MARK: Collection view Flow Layout set up

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width // width
        
        var height: CGFloat = 40 + 8 + 8 // userProfileImageView, usernameLabel, optionButton
        height += width // photoImageView
        height += 44 // actionButtons
        height += 70 // captionLabel
        
        return CGSize(width: width, height: height)
    }
    
}
