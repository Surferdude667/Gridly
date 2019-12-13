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
    let line = CAShapeLayer()
    
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
        
//        let x = CGPoint(x: 100.0, y: 150.0)
//        let y = CGPoint(x: 200.0, y: 250.0)
        
        let x = CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y)
        let y = CGPoint(x: squarePath.bounds.origin.x + squarePath.bounds.width, y: squarePath.bounds.origin.y)
        
        
        addLine(fromPoint: x, toPoint: y)
    }
    
    
    func addLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.red.cgColor
        line.lineWidth = 1
        line.lineJoin = CAShapeLayerLineJoin.round
        self.view.layer.addSublayer(line)
        print("Line added")
    }
        
    
    //  TODO: This function is being called 2 times on iPhone
    override func viewDidLayoutSubviews() {
        print("Called")
        createMask()
        drawGrid()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

