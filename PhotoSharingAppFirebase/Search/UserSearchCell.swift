//
//  UserSearchCell.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/6/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            userProfileImage.loadImage(urlString: user?.profileImageUrl)
            usernameLabel.text = user?.username
        }
    }
    
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

extension UserSearchCell {
    
    fileprivate func setupUpViews() {
        addSubview(userProfileImage)
        addSubview(usernameLabel)
        addSubview(seperatorView)
        
        userProfileImage.anchor(top: nil, right: nil, left: leftAnchor, bottom: nil, paddingTop: 0, paddingRight: 0, paddingLeft: 8, paddingBottom: 0, width: 50, height: 50)
        userProfileImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userProfileImage.layer.cornerRadius = 50 / 2
        
        usernameLabel.anchor(top: topAnchor, right: rightAnchor, left: userProfileImage.rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 12, paddingBottom: 0, width: 0, height: 0)
        
        seperatorView.anchor(top: nil, right: rightAnchor, left: usernameLabel.leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 0.5)
    }
    
}

