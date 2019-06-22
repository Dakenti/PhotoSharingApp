//
//  CameraController.swift
//  PhotoSharingAppFirebase
//
//  Created by Dake Aga on 4/9/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    
    let output = AVCapturePhotoOutput()
    
    let customAnimationPresenter = CustomAnimationPresenter()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhotoButton), for: .touchUpInside)
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "right_arrow_shadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupCaptureSession()
        setupHUD()
    }

}

// MARK: Capture Session configurations

extension CameraController: AVCapturePhotoCaptureDelegate, AVCapturePhotoFileDataRepresentationCustomizer {
    
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        // 1. setup inputs
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input", err)
        }
        // 2. Setup outputs
        let output = AVCapturePhotoOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        // 3. Setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissButton)
        
        capturePhotoButton.anchor(top: nil, right: nil, left: nil, bottom: view.bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: -24, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        dismissButton.anchor(top: view.topAnchor, right: view.rightAnchor, left: nil, bottom: nil, paddingTop: 24, paddingRight: -16, paddingLeft: 0, paddingBottom: 0, width: 50, height: 50)
    }
    
    @objc func handleDismissButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCapturePhotoButton() {
        print("Capturing photo...")
        
        let settings = AVCapturePhotoSettings()
        
        // do not execute camera capture for simulator
        #if (!arch(x86_64))
            guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        
            output.capturePhoto(with: settings, delegate: self)
        #endif
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        
        let previewImage = UIImage(data: imageData!)
        
        let previewPhotoContainerView = PreviewPhotoContainerView()
        previewPhotoContainerView.previewImageView.image = previewImage
        view.addSubview(previewPhotoContainerView)
        previewPhotoContainerView.anchor(top: view.topAnchor, right: view.rightAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingRight: 0, paddingLeft: 0, paddingBottom: 0, width: 0, height: 0)
    }
}

extension CameraController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresenter
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
}


