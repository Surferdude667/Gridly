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
    
    
    func troubleAlert(errorMessage: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Bummer!", message: errorMessage, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Got it..", style: .cancel)
            alertController.addAction(confirmAction)
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
            let noPermissionMessage = "Access denied!"
            
            switch status {
            case .authorized:
                presentImagePicker(sourceType: photos)
            case .denied, .restricted:
                troubleAlert(errorMessage: noPermissionMessage)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: photos)
                    } else {
                        self.troubleAlert(errorMessage: noPermissionMessage)
                    }
                })
            default:
                print("Unknown error!")
            }
            
        } else {
            troubleAlert(errorMessage: "You have no photos in your library! 😢")
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
                print("Full access to camera!")
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                print("No access to camera!")
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(errorMessage: noPermissionMessage)
                    }
                })
            default:
                print("Unknown error!")
            }
        } else {
            troubleAlert(errorMessage: "Can't access camera.")
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
