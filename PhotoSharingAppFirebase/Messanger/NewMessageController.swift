//
//  NewMessageController.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 1/16/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var messageController: MessageController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelButton))
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellId)
        
        fetch()
    }
    
    @objc func handleCancelButton(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetch(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                var user = User(uid: "", dictionary: dictionary)
                user.uid = snapshot.key
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("dismissed new message controller")
            let user = self.users[indexPath.item]
            self.messageController?.showChatLogControllerMessages(user: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.email
        
        if let imageUrl = user.profileImageUrl {
            cell.profileImage.loadImagesUsingCacheWithURL(urlString: imageUrl)
        }
        
        return cell
    }
    
}

