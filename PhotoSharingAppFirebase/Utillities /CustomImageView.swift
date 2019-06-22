//
//  CustomImageView.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/4/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class CustomImageView: UIImageView {
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String?){
        guard let imageUrlString = urlString else { return }
        guard let imageUrl = URL(string: imageUrlString) else { return }
        
        lastURLUsedToLoadImage = imageUrlString
        
        self.image = nil // to remove flickering
        
        if let cachedImage = imageCache[imageUrlString] {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            if imageUrl.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            guard let image = UIImage(data: imageData) else { return }
            // caching images
            imageCache[imageUrl.absoluteString] = image
            
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
}


