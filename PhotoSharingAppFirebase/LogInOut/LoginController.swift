//
//  LoginController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 3/29/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let goSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedString = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributedString.append(NSAttributedString(string: " Sign Up.", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(r: 17, g: 154, b: 237)]))
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    let upperPortionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 120, b: 175)
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        button.setTitle("Sign In", for: .normal)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.isNavigationBarHidden = true
        
        
        setupUpperView()
        setupSignUpButton()
        setupInputFields()
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }

        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if err != nil {
                print(err ?? "")
                return
            }
            
            print("Logged in successfully!")
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleShowSignUp(){
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    fileprivate func setupUpperView() {
        view.addSubview(upperPortionView)
        upperPortionView.anchor(top: view.topAnchor, right: view.rightAnchor, left: view.leftAnchor, bottom: nil, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: view.frame.height / 4)
    }
    
    fileprivate func setupSignUpButton() {
        view.addSubview(goSignUpButton)
        goSignUpButton.anchor(top: nil, right: view.rightAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: -16, width: 0, height: 50)
    }
    
    fileprivate func setupInputFields(){
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: upperPortionView.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, bottom: nil, paddingTop: 40, paddingRight: -40, paddingLeft: 40, paddingBottom: 0, width: 0, height: 140)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.isEmpty != true && passwordTextField.text?.isEmpty != true
        
        if isFormValid {
            signInButton.isEnabled = true
            signInButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        }
    }
    
}
