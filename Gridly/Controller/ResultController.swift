//
//  ResultController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 07/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ResultController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var score = ""
    var buttonWidth: CGFloat = 130.0
    var buttonHeight: CGFloat = 40.0
    var buttonSpacer: CGFloat = 15.0
    
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var iPhonePortraitConstraints: [NSLayoutConstraint] = []
    private var iPhoneLandscapeConstraints: [NSLayoutConstraint] = []
    private var iPadPortraitConstraints: [NSLayoutConstraint] = []
    private var iPadLandscapeConstraints: [NSLayoutConstraint] = []
    
    private lazy var viewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shareButton: UIButton = {
        let shareButton = UIButton(type: .custom)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(displaySharingOptions), for: UIControl.Event.touchUpInside)
        shareButton.setTitle("Share result", for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        shareButton.backgroundColor = UIColor.white
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.layer.cornerRadius = 7.0
        shareButton.setTitleColor(UIColor.black, for: .normal)
        shareButton.setTitleColor(UIColor.white, for: .highlighted)
        shareButton.setImage(UIImage(named: "dice_black"), for: .normal)
        shareButton.setImage(UIImage(named: "dice_white"), for: .highlighted)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 70)
        shareButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -30, bottom: 0, right: 0)
        return shareButton
    }()
    
    private lazy var newGameButton: UIButton = {
        let libraryButton = UIButton(type: .custom)
        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.addTarget(self, action: #selector(unwindToStart), for: UIControl.Event.touchUpInside)
        libraryButton.setTitle("New game", for: .normal)
        libraryButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        libraryButton.backgroundColor = UIColor.white
        libraryButton.imageView?.contentMode = .scaleAspectFit
        libraryButton.layer.cornerRadius = 7.0
        libraryButton.setTitleColor(UIColor.black, for: .normal)
        libraryButton.setTitleColor(UIColor.white, for: .highlighted)
        libraryButton.setImage(UIImage(named: "library_black"), for: .normal)
        libraryButton.setImage(UIImage(named: "library_white"), for: .highlighted)
        libraryButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 60)
        libraryButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -40, bottom: 0, right: 0)
        return libraryButton
    }()
    
    private lazy var scoreLabel: UILabel = {
        let scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = UIFont(name: "Obvia-Light", size: 14.0)
        scoreLabel.text = score
        scoreLabel.textColor = UIColor.white
        return scoreLabel
    }()
    
    private lazy var gratzLabel: UILabel = {
        let gratzLabel = UILabel()
        gratzLabel.translatesAutoresizingMaskIntoConstraints = false
        gratzLabel.font = UIFont(name: "Obvia-Light", size: 14.0)
        gratzLabel.text = "Congratulation! 😍"
        gratzLabel.textColor = UIColor.white
        gratzLabel.textAlignment = .center
        return gratzLabel
    }()
    
    
    private lazy var resultImage: UIImageView = {
        let resultImage = UIImageView()
        resultImage.translatesAutoresizingMaskIntoConstraints = false
        resultImage.contentMode = .scaleAspectFill
        return resultImage
    }()
    
    
    func setupConstraints() {
        sharedConstraints.append(contentsOf: [
            viewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            viewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            viewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            viewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            
            scoreLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: resultImage.bottomAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 200.0),
            scoreLabel.heightAnchor.constraint(equalToConstant: 100.0),
            
            gratzLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            gratzLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            gratzLabel.widthAnchor.constraint(equalToConstant: 200.0),
            gratzLabel.heightAnchor.constraint(equalToConstant: 100.0),
            
            shareButton.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            shareButton.topAnchor.constraint(equalTo: gratzLabel.bottomAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            shareButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            newGameButton.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            newGameButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            newGameButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            resultImage.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            resultImage.topAnchor.constraint(equalTo: viewContainer.topAnchor),
            resultImage.widthAnchor.constraint(equalToConstant: 200.0),
            resultImage.heightAnchor.constraint(equalToConstant: 200.0),
        ])
        
        iPhonePortraitConstraints.append(contentsOf: [
            //
        ])
        
        iPhoneLandscapeConstraints.append(contentsOf: [
           //
        ])
        
        iPadPortraitConstraints.append(contentsOf: [
            //
        ])
        
        iPadLandscapeConstraints.append(contentsOf: [
            //
        ])
    }
    
    func layoutTrait() {
        NSLayoutConstraint.activate(sharedConstraints)
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            //  iPhone Landscape
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                NSLayoutConstraint.deactivate(iPhonePortraitConstraints)
                NSLayoutConstraint.deactivate(iPadLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.activate(iPhoneLandscapeConstraints)
            } else {
                NSLayoutConstraint.deactivate(iPhoneLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.deactivate(iPadLandscapeConstraints)
                NSLayoutConstraint.activate(iPhonePortraitConstraints)
            }
        case .pad:
            //  iPad Landscape
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.deactivate(iPhoneLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.activate(iPadLandscapeConstraints)
            } else {
                //  iPad Portrait
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.deactivate(iPhoneLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPhonePortraitConstraints)
                NSLayoutConstraint.activate(iPadLandscapeConstraints)
            }
        default:
            break
        }
    }
    
    func setupUI() {
        view.addSubview(viewContainer)
        viewContainer.addSubview(shareButton)
        viewContainer.addSubview(newGameButton)
        viewContainer.addSubview(scoreLabel)
        viewContainer.addSubview(gratzLabel)
        viewContainer.addSubview(resultImage)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutTrait()
    }
    
    func configure() {
        setupUI()
        setupConstraints()
        layoutTrait()
        self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        
        if let image = Tile.croppedImage {
            resultImage.image = image
        }
        
        if let backgroundImage = Tile.originalImage {
            backgroundView.image = backgroundImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    @objc func displaySharingOptions() {
        let message = score
        let image = Tile.croppedImage!
        let items = [image as Any, message as Any]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func unwindToStart() {
        performSegue(withIdentifier: "unwindToStart", sender: self)
    }
    
}
