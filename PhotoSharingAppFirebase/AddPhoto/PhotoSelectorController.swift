//
//  PhotoSelectorController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/1/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var selectedImage: UIImage?
    var header: PhotoSelectorHeader?
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        setupNavigationButton()
        fetchPhotos()
    }
    
}

// MARK: Setting up PhotoSelectorController appereance

extension PhotoSelectorController {
    fileprivate func setupNavigationButton() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.image = selectedImage
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
}

// MARK: Setting up Collection View

extension PhotoSelectorController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        self.collectionView.reloadData()
        
        let index = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: index, at: .bottom, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
}

// MARK: Setting up Collection View`s Header

extension PhotoSelectorController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        header.photoImageView.image = selectedImage
        self.header = header
        setImageToHeaderPortion()

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
}

// MARK: Fetching photos from device using Photos framework

extension PhotoSelectorController {
    
    fileprivate func fetchPhotos(){
        
        DispatchQueue.global(qos: .background).async {
            let allPhotos = PHAsset.fetchAssets(with: .image, options: self.fetchOptions())
            allPhotos.enumerateObjects { (asset, count, stop) in
                
                let imageManeger = PHImageManager.default()
                let targetSize = CGSize(width: 150, height: 150)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManeger.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in
                    
                    guard let image = image else { return }
                    self.images.append(image)
                    self.assets.append(asset)
                    
                    if self.selectedImage == nil {
                        self.selectedImage = image
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                })
                
            }
        }
        
    }
    
    fileprivate func fetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
//        fetchOptions.fetchLimit = 30
        let sortDescription = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchOptions.sortDescriptors = [sortDescription]
        
        return fetchOptions
    }
    
    fileprivate func setImageToHeaderPortion(){
        guard let image = selectedImage else { return }
        guard let index = images.firstIndex(of: image) else { return }
        
        let imageManager = PHImageManager()
        imageManager.requestImage(for: assets[index], targetSize: CGSize(width: 600, height: 600), contentMode: .default, options: nil) { (image, info) in
            
            self.header?.photoImageView.image = image
            
        }
    }
    
}















