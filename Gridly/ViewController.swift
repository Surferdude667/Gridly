//
//  ViewController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 09/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let backgroundImage = UIView()
    var squarePath = UIBezierPath()
    let gridLayer = CALayer()
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var testImageView: UIImageView!
    
    func createMask() {
        backgroundImage.frame = self.view.frame
        backgroundImage.backgroundColor =  UIColor.white.withAlphaComponent(0.6)
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
    
    func drawGrid() {
        var horizontalOffset: CGFloat = 0.0
        var verticalOffset: CGFloat = 0.0
        let offsetCalculation: CGFloat = squarePath.bounds.width / 4
        gridLayer.sublayers?.removeAll()
        
        for _ in 0..<5 {
            let x = CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y + horizontalOffset)
            let y = CGPoint(x: squarePath.bounds.origin.x + squarePath.bounds.width, y: squarePath.bounds.origin.y + horizontalOffset)
            drawLine(fromPoint: x, toPoint: y)
            horizontalOffset = horizontalOffset + offsetCalculation
        }
        
        for _ in 0..<5 {
            let x = CGPoint(x: squarePath.bounds.origin.x + verticalOffset, y: squarePath.bounds.origin.y)
            let y = CGPoint(x: squarePath.bounds.origin.x + verticalOffset, y: squarePath.bounds.origin.y + squarePath.bounds.width)
            drawLine(fromPoint: x, toPoint: y)
            verticalOffset = verticalOffset + offsetCalculation
        }
    }
    
    func drawLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 1
        line.lineJoin = CAShapeLayerLineJoin.round
        
        gridLayer.addSublayer(line)
        self.view.layer.addSublayer(gridLayer)
    }
    
    @objc func changeImage(_ sender: Any) {
        print("Tapped!")
    }
    
    func configure() {
        backgroundImage.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
        backgroundImage.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
    }
    
    func bringViewsToTop() {
        self.view.bringSubviewToFront(testImageView)
    }
    
    override func viewDidLayoutSubviews() {
        createMask()
        drawGrid()
        bringViewsToTop()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

}

