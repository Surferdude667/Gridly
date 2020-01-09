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
    
    @IBOutlet weak var buttonPickRandom: UIButton!
    
    var localImages = [UIImage]()
    
    
    // --------------------------------------
    
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    
    private lazy var viewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var randomButton: UIButton = {
        let randomButton = UIButton(type: .system)
        randomButton.translatesAutoresizingMaskIntoConstraints = false
        randomButton.backgroundColor = UIColor.green
        randomButton.setTitle("Button", for: .normal)
        randomButton.addTarget(self, action: #selector(randomImage), for: UIControl.Event.touchUpInside)
        
        return randomButton
    }()

    
    func setupUI() {
        buttonPickRandom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewContainer)
        viewContainer.addSubview(randomButton)
    }
    
    func setupConstraints() {
        sharedConstraints.append(contentsOf: [
            viewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            viewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            viewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            viewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            
        ])

        regularConstraints.append(contentsOf: [
            randomButton.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            randomButton.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            randomButton.widthAnchor.constraint(equalTo: viewContainer.widthAnchor)
        ])

        compactConstraints.append(contentsOf: [
            randomButton.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
            randomButton.leftAnchor.constraint(equalTo: viewContainer.leftAnchor),
            randomButton.widthAnchor.constraint(equalTo: viewContainer.widthAnchor)
        ])
    }
    
    
    func layoutTrait(traitCollection:UITraitCollection) {
        if (!sharedConstraints[0].isActive) {
           // activating shared constraints
           NSLayoutConstraint.activate(sharedConstraints)
        }
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutTrait(traitCollection: traitCollection)
    }
    
    
    // --------------------------------------
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectLocalImages()
        
        setupUI()
        setupConstraints()

        NSLayoutConstraint.activate(sharedConstraints)
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
        
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
    
    @objc func chooseRandomImage() -> UIImage? {
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
    
    @objc func randomImage() {
        processedPicked(image: chooseRandomImage())
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
