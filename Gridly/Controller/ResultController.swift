//
//  ResultController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 07/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ResultController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultScore: UILabel!
    
    var score = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultScore.text = score
        
        if let image = Tile.croppedImage {
            resultImage.image = image
        }
        
    }
    
    func displaySharingOptions() {
        let message = score
        let image = Tile.croppedImage!
        let items = [image as Any, message as Any]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        
        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func buttonShare(_ sender: Any) {
        displaySharingOptions()
    }
    
}
