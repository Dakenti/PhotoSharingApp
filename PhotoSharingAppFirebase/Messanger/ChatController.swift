//
//  ChatController.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 2/6/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    
    var messages = [Message]()
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var user: User? {
        didSet{
            navigationItem.title = user?.username
            
            observeMessages()
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type Your Message Here"
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "Chat Log Controller"
        
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.backgroundColor = .white
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
//        setupChatController()
//
//        setupKeyboardObserver()
        setupKeyboardObserverToUpshiftMessages()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
    
    func setupKeyboardObserverToUpshiftMessages(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleMessagesUpshift), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleMessagesUpshift(){
        if self.messages.count > 0 {
            let indexPath: IndexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView()
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageSelection)))
        
        containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendButtonPress), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 16).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    @objc func handleImageSelection(){
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelectedForUrl(url: videoUrl)
        } else {
            handleImageSelectedForInfo(info: info)
        }
       
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url: URL){
        let filename = "SomeVideo.mov"
        let storageUrl = Storage.storage().reference().child(filename)
        
        let uploadTask = storageUrl.putFile(from: url, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print(error ?? "error in video uploading")
            }
        
            storageUrl.downloadURL(completion: { (videoUrl, error) in
                if error != nil {
                    print(error ?? "error in download URL")
                }
                guard let videoUrl = videoUrl else { fatalError() }
                
                let properties: [String : AnyObject] = ["videoUrl" : videoUrl as AnyObject ]
                self.sendProperties(properties: properties)
            })
        }
        
        uploadTask.observe(.progress) { (task) in
            if let taskProgress = task.progress?.completedUnitCount {
                self.navigationItem.title = String(taskProgress)
            }
        }
        
        uploadTask.observe(.success) { (task) in
            self.navigationItem.title = self.user?.username
        }
    }
    
    private func handleImageSelectedForInfo(info: [UIImagePickerController.InfoKey : Any]){
        var selectedImage: UIImage?
        
        if let oiginalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = oiginalImage
        } else if let editedImage = info[UIImagePickerController.InfoKey.cropRect] as? UIImage{
            selectedImage = editedImage
        }
        
        if let finalImage = selectedImage {
            uploadImageToFirebase(image: finalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImageToFirebase(image: UIImage){
        let uniqueImageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child(uniqueImageName)
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil{
                    print(error ?? "error while trying to upload image to Firebase")
                    return
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    self.sendMessageWithImageURL(imageUrl: url?.absoluteString ?? "", image: image)
                })
            }
        }
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
//    func setupKeyboardObserver(){
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc func handleKeyboardWillShow(notification: Notification){
//        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { fatalError() }
//
//        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue  else { fatalError() }
//
//        self.containerViewBottomAnchor?.constant = -keyboardFrame.height
//        UIView.animate(withDuration: duration) {
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    @objc func handleKeyboardWillHide(notification: Notification){
//        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { fatalError() }
//
//        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: duration) {
//            self.view.layoutIfNeeded()
//        }
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.uid else { fatalError() }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messagesRef = Database.database().reference().child("messages").child(snapshot.key)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else { fatalError() }
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    
                    let indexPath: IndexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    
                }
                
                
            }, withCancel: nil)

        }, withCancel: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButtonPress()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatControllerDelegate = self
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubleViewWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubleViewWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        guard let imageUrl = user?.profileImageUrl else { fatalError() }
        cell.profileImageView.loadImagesUsingCacheWithURL(urlString: imageUrl)
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubleViewRightAnchor?.isActive = true
            cell.bubleViewLeftAnchor?.isActive = false
        } else {
            cell.bubleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubleViewRightAnchor?.isActive = false
            cell.bubleViewLeftAnchor?.isActive = true
        }
        
        if let sentImage = message.imageUrl {
            cell.messageImageView.loadImagesUsingCacheWithURL(urlString: sentImage)
            cell.bubleView.backgroundColor = .clear
        } else if message.imageUrl == nil {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        } else if let imageHeight = message.imageHeight?.floatValue, let imageWidth = message.imageWidth?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleSendButtonPress(){
       let properties = ["text": inputTextField.text!]
        sendProperties(properties: properties as [String : AnyObject])
    }
    
    private func sendMessageWithImageURL(imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendProperties(properties: properties)
    }
    
    private func sendProperties(properties: [String: AnyObject]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.uid
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
//        properties.forEach { (arg0) in
//            let (key, value) = arg0
//            values[key] = value
//        }
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil

            guard let messageId = childRef.key else { return }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId).child(messageId)
            userMessagesRef.setValue(1)
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId).child(messageId)
            recipientUserMessagesRef.setValue(1)
        }
    }
    
}

extension ChatController: ImageZoomInAndOutHelper {
    
    
    func performZoomInWithStartingImage(startingImage: UIImageView) {
        startingFrame = startingImage.superview?.convert(startingImage.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImage.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomingOutImageView = tapGesture.view {
            zoomingOutImageView.layer.cornerRadius = 16
            zoomingOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                
                zoomingOutImageView.frame = self.startingFrame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }) { (completed: Bool) in
                
                zoomingOutImageView.removeFromSuperview()
                
            }
            
        }
    }
}
