//
//  CommentCell.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/10/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { fatalError() }
            guard let userProfileImageUrl = comment.user?.profileImageUrl else { fatalError() }
            
            userProfileImage.loadImage(urlString: userProfileImageUrl)
            commentTextView.attributedText = setUsernameWithComment()
        }
    }
    
    let userProfileImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.text = "Username"
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        return tv
    }()
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CommentCell {
    
    fileprivate func setupUpViews() {
        addSubview(userProfileImage)
        addSubview(commentTextView)
        addSubview(seperatorView)
        
        userProfileImage.anchor(top: nil, right: nil, left: leftAnchor, bottom: nil, paddingTop: 0, paddingRight: 0, paddingLeft: 8, paddingBottom: 0, width: 50, height: 50)
        userProfileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userProfileImage.layer.cornerRadius = 50 / 2
        
        commentTextView.anchor(top: topAnchor, right: rightAnchor, left: userProfileImage.rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 12, paddingBottom: 0, width: 0, height: 0)
        
        seperatorView.anchor(top: nil, right: rightAnchor, left: commentTextView.leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 0.5)
    }
    
    fileprivate func setUsernameWithComment() -> NSAttributedString {
        guard let comment = comment else { fatalError() }
        guard let username = comment.user?.username else { fatalError() }
        guard let text = comment.text else { fatalError() }
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " " + text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        return attributedText
    }
    
}


