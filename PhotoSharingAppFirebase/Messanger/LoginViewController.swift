//
//  LoginViewController.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 1/12/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var messageController: MessageController?
    
    lazy var loginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "gameofthrones_splash")
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageSelection)))
        
        return imageView
    }()
    
    let inputsContainerView: UIView = {
        let cont = UIView()
        cont.translatesAutoresizingMaskIntoConstraints = false
        cont.backgroundColor = .white
        cont.layer.cornerRadius = 5
        cont.layer.masksToBounds = true
        return cont
    }()
    
    lazy var registerLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginRegisterSelection), for: .touchUpInside)
        
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.delegate = self
        return tf
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        
        sc.addTarget(self, action: #selector(handleToggleOfSegmentControl), for: .valueChanged)
        
        return sc
    }()
    
    var heightAnchorOfInputContainerView: NSLayoutConstraint?
    var heightAnchorOfNameTextField: NSLayoutConstraint?
    var heightAnchorOfEmailTextField: NSLayoutConstraint?
    var heightAnchorOfPasswordTextField: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(registerLoginButton)
        view.addSubview(loginImageView)
        view.addSubview(segmentedControl)
        
        setupInputContainerView()
        setupRegisterLoginButton()
        setupLoginImageView()
        setupSegmentedControl()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginViewController {
    
    @objc func handleLoginRegisterSelection(){
        if segmentedControl.selectedSegmentIndex == 1 {
            handleRegisterButtonPress()
        } else {
            handleLoginButtonPress()
        }
    }
    
    @objc func handleLoginButtonPress(){
        guard let email = emailTextField.text, let password = passwordTextField.text else { fatalError() }

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error ?? "error")
                return
            }
            self.messageController?.fetchUserIsLoggedIn()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleRegisterButtonPress(){
        uploadImagesToFirebaseAndLinkWithUserData()
    }
    
    @objc func handleToggleOfSegmentControl() {
        let title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        
        registerLoginButton.setTitle(title, for: .normal)
        
        heightAnchorOfInputContainerView?.constant = segmentedControl.selectedSegmentIndex == 1 ? 150 : 100
        heightAnchorOfInputContainerView?.isActive = true
        
        heightAnchorOfNameTextField?.isActive = false
        heightAnchorOfNameTextField = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 1 ? 1/3 : 0)
        heightAnchorOfNameTextField?.isActive = true
        
        heightAnchorOfEmailTextField?.isActive = false
        heightAnchorOfEmailTextField = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 1 ? 1/3 : 1/2)
        heightAnchorOfEmailTextField?.isActive = true
        
        heightAnchorOfPasswordTextField?.isActive = false
        heightAnchorOfPasswordTextField = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 1 ? 1/3 : 1/2)
        heightAnchorOfPasswordTextField?.isActive = true
    }

}

// Handling Profile Image Selection

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleImageSelection(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            loginImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // handle image upload to firebase
    
    private func uploadImagesToFirebaseAndLinkWithUserData(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {fatalError()}
        
        let uniqueImageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("user_images").child("\(uniqueImageName).jpeg")
        if let uploadImage = self.loginImageView.image?.jpegData(compressionQuality: 0.1) {
            storageRef.putData(uploadImage, metadata: nil) { (metadata, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if err != nil{
                        print(err ?? "")
                        return
                    }
                    
                    guard let url = url else {return}
                    let values = ["name" : name, "email" : email, "loginImage" : url.absoluteString]
                    self.addUserWithEmailAndPassword(email: email, password: password, values: values as [String : AnyObject])
                })
            }
        }
        
        
    }
    
    private func addUserWithEmailAndPassword(email: String, password: String, values: [String : AnyObject]){
        Auth.auth().createUser(withEmail: email, password: password) { (res, error) in
            if error != nil {
                print(error ?? "error")
                return
            }
            
            guard let uid = res?.user.uid else { fatalError() }
            
            let ref = Database.database().reference()
            let userReferences = ref.child("users").child(uid)
            
            userReferences.updateChildValues(values, withCompletionBlock: { (err, reff) in
                if err != nil {
                    print(err ?? "err")
                    return
                }
                
//                self.messageController?.navigationItem.title = values["name"] as? String
                let user = User(uid: uid, dictionary: values)
                self.messageController?.setupCustomNavbar(user: user)
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}

extension LoginViewController {
    
    func setupInputContainerView(){
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        heightAnchorOfInputContainerView = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        heightAnchorOfInputContainerView?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        setupNameTextField()
        setupNameSeparatorView()
        setupEmailTextField()
        setupEmailSeparatorView()
        setupPasswordTextField()
    
    }
    
    func setupRegisterLoginButton(){
        registerLoginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        registerLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerLoginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupLoginImageView(){
        loginImageView.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -12).isActive = true
        loginImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupSegmentedControl(){
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupNameTextField() {
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        heightAnchorOfNameTextField = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        heightAnchorOfNameTextField?.isActive = true
    }
    
    func setupNameSeparatorView() {
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func setupEmailTextField() {
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        heightAnchorOfEmailTextField = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        heightAnchorOfEmailTextField?.isActive = true
    }
    func setupEmailSeparatorView() {
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func setupPasswordTextField() {
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        heightAnchorOfPasswordTextField = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        heightAnchorOfPasswordTextField?.isActive = true
    }
}

















