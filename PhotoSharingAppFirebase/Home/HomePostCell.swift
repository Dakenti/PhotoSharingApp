//
//  HomePostCell.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/5/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapCommentButton(post: Post)
    func didLike(for cell: HomePostCell)
    func sendMessageButtonPressed(to toUser: String)
}

class HomePostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            photoImageView.loadImage(urlString: post?.imageUrl)
            userProfileImage.loadImage(urlString: post?.user.profileImageUrl)
            usernameLabel.text = post?.user.username
            captionLabel.attributedText = setupAttributtedCaption()
            likeButton.setImage(post?.isLiked == true ? UIImage(named: "like_selected")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    var delegate: HomePostCellDelegate?
    
    let userProfileImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        return button
    }()
    
    lazy var sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "send2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSendbuttonPressed), for: .touchUpInside)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupOfUpperPortionOfCell()
        setupOfBottomPortionOfCell()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Home Post Cell view set up

extension HomePostCell {
    
    fileprivate func setupOfUpperPortionOfCell() {
        addSubview(userProfileImage)
        addSubview(usernameLabel)
        addSubview(optionButton)
        addSubview(photoImageView)
        
        userProfileImage.anchor(top: topAnchor, right: nil, left: leftAnchor, bottom: photoImageView.topAnchor, paddingTop: 8, paddingRight: 0, paddingLeft: 8, paddingBottom: -8, width: 40, height: 40)
        userProfileImage.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: topAnchor, right: optionButton.leftAnchor, left: userProfileImage.rightAnchor, bottom: photoImageView.topAnchor, paddingTop: 0, paddingRight: -4, paddingLeft: 8, paddingBottom: 0, width: 0, height: 0)
        
        optionButton.anchor(top: topAnchor, right: rightAnchor, left: usernameLabel.rightAnchor, bottom: photoImageView.topAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 4, paddingBottom: -4, width: 0, height: 0)
        
        
        photoImageView.anchor(top: userProfileImage.bottomAnchor, right: rightAnchor, left: leftAnchor, bottom: nil, paddingTop: 8, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 1).isActive = true
    }
    
    fileprivate func setupOfBottomPortionOfCell() {
        setupActionButtons()
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, right: rightAnchor, left: nil, bottom: nil, paddingTop: 8, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 44, height: 34)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, right: rightAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: -4, paddingLeft: 8, paddingBottom: 0, width: 0, height: 0)
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.anchor(top: photoImageView.bottomAnchor, right: nil, left: leftAnchor, bottom: nil, paddingTop: 8, paddingRight: 0, paddingLeft: 8, paddingBottom: 0, width: 120, height: 44)
    }
    
    fileprivate func setupAttributtedCaption() -> NSMutableAttributedString {
        guard let username = post?.user.username else { fatalError() }
        guard let caption = post?.caption else { fatalError() }
        
        let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(string: "\(username): ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: caption, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 4)]))
        
        guard let timeToDisplay = post?.creationDate.timeAgoDisplay() else { fatalError() }
        attributedText.append(NSAttributedString(string: timeToDisplay, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return attributedText
    }
    
    @objc func handleCommentButton(){
        guard let post = post else { return }
        delegate?.didTapCommentButton(post: post)
    }
    
    @objc func handleLikeButton() {
        delegate?.didLike(for: self)
    }
    
    @objc func handleSendbuttonPressed() {
        guard let post = post else { return }
        delegate?.sendMessageButtonPressed(to: post.user.uid)
    }
}





