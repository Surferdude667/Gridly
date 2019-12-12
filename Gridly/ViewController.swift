//
//  ViewController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 09/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let backgroundImage = UIView()
    var squarePath = UIBezierPath()
    
    @IBOutlet weak var background: UIImageView!
        
    func createMask() {
        backgroundImage.frame = self.view.frame
        backgroundImage.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(backgroundImage)
        
        var squareSize = CGFloat()
        let maskLayer = CALayer()
        let squareLayer = CAShapeLayer()
        
        if UIDevice.current.orientation.isLandscape {
            squareSize = self.backgroundImage.bounds.height - 50
        } else {
            squareSize = self.backgroundImage.bounds.width - 50
        }
        
        squareLayer.frame = CGRect(x: 0, y: 0, width: backgroundImage.frame.size.width, height: backgroundImage.frame.size.height)
        
        let overlay = UIBezierPath(rect: CGRect(x: 0, y: 0, width: backgroundImage.frame.size.width, height: backgroundImage.frame.size.height))
    
        squarePath = UIBezierPath(rect: CGRect(x: backgroundImage.center.x - squareSize / 2, y: backgroundImage.center.y - squareSize / 2, width: squareSize, height: squareSize))
        
        overlay.append(squarePath.reversing())
        squareLayer.path = overlay.cgPath
        maskLayer.addSublayer(squareLayer)
        
        backgroundImage.layer.mask = maskLayer
    }
    
    //  TODO: Make the grid layout
    func drawGrid() {
        print("Hej")
        print(squarePath.bounds.origin.x)
        print(squarePath.bounds.origin.y)
    }
    
    //  TODO: This function is being called 2 times on iPhone
    override func viewDidLayoutSubviews() {
        drawGrid()
        createMask()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

