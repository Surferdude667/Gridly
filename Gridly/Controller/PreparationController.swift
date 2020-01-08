//
//  PreparationController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 07/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class PreparationController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var localImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectLocalImages()
    }
    
    
    func troubleAlert(errorMessage: String, linkToSettings: Bool) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Oops! 😓", message: errorMessage, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alertController.addAction(cancelAction)
            
            if linkToSettings {
                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (success) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
                
                alertController.addAction(settingsAction)
            }
            self.present(alertController, animated: true)
        }
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func displayLibrary() {
        
        let photos = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(photos) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "We don't have access to your photos."
            
            switch status {
            case .authorized:
                presentImagePicker(sourceType: photos)
            case .denied, .restricted:
                troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: photos)
                    } else {
                        self.troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
                    }
                })
            default:
                troubleAlert(errorMessage: "We can't access your photos. Maybe you didn't give us access?", linkToSettings: true)
            }
            
        } else {
            troubleAlert(errorMessage: "You don't seem to have any photos in your library.", linkToSettings: false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        processedPicked(image: newImage)
    }
    
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "No permission to camera."
            
            switch status {
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
                    }
                })
            default:
                troubleAlert(errorMessage: "We can't access your camera. Maybe you didn't give us access?", linkToSettings: true)
            }
        } else {
            troubleAlert(errorMessage: "There was a problem with your camera.", linkToSettings: false)
        }
    }
    
    func chooseRandomImage() -> UIImage? {
        let currentImage = Tile.originalImage
        
        if localImages.count > 0 {
            while true {
                
                let randomIndex = Int.random(in: 0..<localImages.count)
                let newImage = localImages[randomIndex]
                
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        return nil
    }
    
    func collectLocalImages() {
        localImages.removeAll()
        let imageNames = ["italy", "waves", "fox", "butterfly", "aurora"]
        
        for name in imageNames {
            if let image = UIImage(named: name) {
                localImages.append(image)
            }
        }
    }
    
    
    func processedPicked(image: UIImage?) {
        if let newImage = image {
            Tile.originalImage = newImage
            performSegue(withIdentifier: "toGameSegue", sender: self)
        }
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func buttonPickRandom(_ sender: Any) {
        processedPicked(image: chooseRandomImage())
    }
    
    @IBAction func buttonPhotoLibrary(_ sender: Any) {
        displayLibrary()
    }
    
    @IBAction func buttonCamera(_ sender: Any) {
        displayCamera()
    }
    
}
