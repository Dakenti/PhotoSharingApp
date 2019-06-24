//
//  File.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 3/25/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        userSignInCheck()
        
        setupViewControllers()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    fileprivate func userSignInCheck() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    func setupViewControllers() {
        //user
        let profileViewController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileNavController = templateNavController(unselectedImage: "profile_unselected", selectedImage: "profile_selected", rootViewController: profileViewController)
        //home
        let homeViewController = HomeController(collectionViewLayout: UICollectionViewFlowLayout())
        let homeNavController = templateNavController(unselectedImage: "home_unselected", selectedImage: "home_selected", rootViewController: homeViewController)
        //search
        let searchViewController = UserSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchNavController = templateNavController(unselectedImage: "search_unselected", selectedImage: "search_selected", rootViewController: searchViewController)
        //plus
        let plusNavController = templateNavController(unselectedImage: "plus_unselected", selectedImage: "plus_selected")
        //like
        let messageController = MessageController(style: .plain)
        let messangerNavSelected = templateNavController(unselectedImage: "send2", selectedImage: "send2_selected", rootViewController: messageController)
        
        viewControllers = [homeNavController,searchNavController,plusNavController,messangerNavSelected,profileNavController]
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    
    fileprivate func templateNavController(unselectedImage: String, selectedImage: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem.image = UIImage(named: unselectedImage)
        navController.tabBarItem.selectedImage = UIImage(named: selectedImage)
        tabBar.tintColor = .black
        
        return navController
    }
    
}








