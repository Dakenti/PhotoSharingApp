//
//  SharePhotoController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/3/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let containerView: UIView = {
        let cont = UIView()
        cont.backgroundColor = .white
        return cont
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        
        setupRightBarButton()
        setupImagesAndTextViews()
    }
    
    fileprivate func setupImagesAndTextViews() {
        view.addSubview(containerView)
        containerView.anchor(top:  view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, bottom: nil, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, right: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, paddingTop: 8, paddingRight: 0, paddingLeft: 8, paddingBottom: -8, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, paddingTop: 8, paddingRight: -8, paddingLeft: 8, paddingBottom: -8, width: 0, height: 0)
    }
    
    fileprivate func setupRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
}

// MARK: Firebase setup

extension SharePhotoController {
    
    @objc func handleNext() {
        guard let selectedImage = image else { return }
        
        let filename = NSUUID().uuidString
        guard let uploadImage = selectedImage.jpegData(compressionQuality: 0.5) else { return }
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadImage, metadata: nil) { (ref, err) in
            if err != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Error during image upload", err ?? "")
                return
            }
            storageRef.downloadURL(completion: { (imageUrl, err) in
                if err != nil {
                    print(err ?? "")
                    return
                }
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            })
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: URL?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postImage = image else { return }
        guard let caption = textView.text, !caption.isEmpty else { return }
        guard let imageUrl = imageUrl?.absoluteString else { return }
        
        let dbRef = Database.database().reference().child("posts").child(uid)
        let ref = dbRef.childByAutoId()
        
        let values = ["imageUrl" : imageUrl, "caption" : caption, "imageWidth" : postImage.size.width, "imageHeight" : postImage.size.height, "creationDate" : Date().timeIntervalSince1970] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if err != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print(err ?? "")
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("UpdateFeed"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}


