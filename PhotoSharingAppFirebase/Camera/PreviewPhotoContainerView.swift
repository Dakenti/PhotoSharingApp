//
//  PreviewPhotoContainerView.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/10/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "cancel_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "save_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    let savedLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Successfully"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0, alpha: 0.3)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc func handleSave() {
        print("Handling save...")
        
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            guard let previewImage = self.previewImageView.image else { return }
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, error) in
            if error != nil {
                print("Error, in saving image to library.", error ?? "")
                return
            }
            DispatchQueue.main.async {
                self.setupSavedLabelAnimation()
            }
        }
    }
    
    fileprivate func setupViewComponents() {
        addSubview(cancelButton)
        addSubview(saveButton)
        
        cancelButton.anchor(top: topAnchor, right: nil, left: leftAnchor, bottom: nil, paddingTop: 12, paddingRight: 0, paddingLeft: 12, paddingBottom: 0, width: 44, height: 44)
        saveButton.anchor(top: nil, right: nil, left: leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 24, paddingBottom: -24, width: 44, height: 44)
    }
    
    fileprivate func setupSavedLabelAnimation() {
        addSubview(savedLabel)
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        savedLabel.center = center
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        animateSavedlabelAppearence()
    }
    
    fileprivate func animateSavedlabelAppearence() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (completed) in
            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                self.savedLabel.alpha = 0
            }, completion: { (completed) in
                self.savedLabel.removeFromSuperview()
            })
        }
    }
    
}




