//
//  CommentController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/10/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class CommentController: UICollectionViewController {
    
    var post: Post?
    var comments = [Comment]()
    var user: User?
    
    let width = UIScreen.main.bounds.width
    let cellId = "cellId"
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.placeholder = "Enter your comment"
        return tf
    }()
    
    lazy var containerView: UIView = {
        let width = UIScreen.main.bounds.width
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: width, height: 70)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, left: nil, bottom: containerView.bottomAnchor, paddingTop: 0, paddingRight: -16, paddingLeft: 0, paddingBottom: 0, width: 50, height: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, right: sendButton.leftAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 16, paddingBottom: 0, width: 0, height: 0)
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        containerView.addSubview(seperatorLineView)
        seperatorLineView.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, left: containerView.leftAnchor, bottom: nil, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 1)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
}

// MARK: Database set up

extension CommentController {
    
    @objc func handleSendButton() {
        print("handle send button")
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
        guard let text = commentTextField.text else { return }
        guard let postId = post?.id else { return }
        
        let values = ["text":text, "creationDate":Date().timeIntervalSince1970, "uid":currentLoggedUserId] as [String:Any]
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if err != nil {
                print("Err, in saving comment to DB", err ?? "")
                return
            }
            print("Successfully saved comment to DB")
        }
    }
    
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            guard let userId = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: userId, completion: { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })

        }) { (err) in
            print("err, in fetching comments",err)
        }
    }
}

// MARK: Setting up collection view config

extension CommentController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummmyCell = CommentCell(frame: frame)
        dummmyCell.comment = comments[indexPath.item]
        dummmyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummmyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max( 50 + 8 + 8, estimatedSize.height )
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
