//
//  UserProfileHeader.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 3/26/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: UICollectionReusableView {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            self.usernameLabel.text = user?.username
            profileImageView.loadImage(urlString: user?.profileImageUrl)
            setupEditFollowButton()
        }
    }
    
    private var followersNumber = 0
    private var followingsNumber: Int? {
        willSet {
            followingLabel.text = "\(newValue)"
        }
    }
        
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 100 / 2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(changeToListView), for: .touchUpInside)
        return button
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
//        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(changeToGridView), for: .touchUpInside)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    let postLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "Post\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "11", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        
        label.numberOfLines = 0
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "Followers\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "\(self.followingsNumber ?? 0)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        
        label.numberOfLines = 0
        label.attributedText = attributedText
        
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "Following\n", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        
        label.numberOfLines = 0
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(handleEditProfileOrFollowButton), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coountFollowingsNumber()
        
        setupProfileImageViewPosition()
        
        setupButtonToolbar()
        
        setupUsernameLabel()
        
        setupUserStats()
                
        setupEditProfileButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserProfileHeader {
    
    fileprivate func setupProfileImageViewPosition() {
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, right: nil, left: leftAnchor, bottom: nil, paddingTop: 12, paddingRight: 0, paddingLeft: 12, paddingBottom: 0, width: 100, height: 100)
    }
    
    fileprivate func setupButtonToolbar(){
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, right: rightAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, right: rightAnchor, left: leftAnchor, bottom: nil, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: nil, right: rightAnchor, left: leftAnchor, bottom: stackView.bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 0.5)
    }
    
    fileprivate func setupUsernameLabel(){
        addSubview(usernameLabel)
        
        usernameLabel.anchor(top: profileImageView.bottomAnchor, right: rightAnchor, left: leftAnchor, bottom: gridButton.topAnchor, paddingTop: 8, paddingRight: 12, paddingLeft: 12, paddingBottom: -4, width: 0, height: 0)
    }
    
    fileprivate func setupUserStats(){
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, right: rightAnchor, left: profileImageView.rightAnchor, bottom: nil, paddingTop: 16, paddingRight: -12, paddingLeft: 12, paddingBottom: 0, width: 0, height: 50)
    }
    
    fileprivate func setupEditProfileButton() {
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: followersLabel.bottomAnchor, right: followingLabel.rightAnchor, left: postLabel.leftAnchor, bottom: usernameLabel.topAnchor, paddingTop: 8, paddingRight: -4, paddingLeft: 16, paddingBottom: -24, width: 0, height: 0)
    }
    
}

// MARK: functionallity

extension UserProfileHeader {
    
    fileprivate func setupEditFollowButton() {
        guard let userId = user?.uid else { return }
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
        
        if currentLoggedUserId == userId {
            //editProfile
        } else {
            Database.database().reference().child("following").child(currentLoggedUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.setupUnfollowStyle()
                } else {
                    self.setupFollowingStyle()
                }
                
            }) { (error) in
                print("error, while checking for user existance",error)
            }
        }
    }
    
    @objc func handleEditProfileOrFollowButton() {
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currentLoggedUserId == userId {
            //editProfile
            currentUserEditProfileButtonPress()
        } else {
            foundSearchUserFollowUnfollowButtonPress(currentLoggedUserId: currentLoggedUserId, userId: userId)
        }
    }
    
    fileprivate func currentUserEditProfileButtonPress() {
        
    }
    
    fileprivate func foundSearchUserFollowUnfollowButtonPress(currentLoggedUserId: String, userId: String) {
        let ref = Database.database().reference().child("following").child(currentLoggedUserId)
        
        if editProfileFollowButton.titleLabel?.text == "Follow" {
            let values = [userId:1]
            ref.updateChildValues(values as [String:Int]) { (err, ref) in
                if err != nil {
                    print("err, in follwing a user", err ?? "")
                    return
                }
                print("started follwoing \(self.user?.username ?? "error")")
                self.setupUnfollowStyle()
            }
        } else {
            ref.child(userId).removeValue { (err, ref) in
                if err != nil {
                    print("err, cannot unfollow",err ?? "")
                    return
                }
                self.setupFollowingStyle()
            }
            
        }
    }
    
    fileprivate func setupFollowingStyle() {
        editProfileFollowButton.setTitle("Follow", for: .normal)
        editProfileFollowButton.setTitleColor(.white, for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        editProfileFollowButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
    }
    
    fileprivate func setupUnfollowStyle() {
        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
        self.editProfileFollowButton.setTitleColor(.black, for: .normal)
        self.editProfileFollowButton.backgroundColor = .white
    }
    
    @objc func changeToGridView() {
        gridButton.tintColor = .mainBlue
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    @objc func changeToListView() {
        listButton.tintColor = .mainBlue
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    private func coountFollowersNumber() {
        
    }
    
    private func coountFollowingsNumber() {
        guard let currentLoggedUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("following").child(currentLoggedUserId)
        ref.observe(.value, with: { (snapshot: DataSnapshot!) in
            self.followingsNumber = Int(snapshot.childrenCount)
        })
    }
}



