//
//  ViewController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 09/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let maskOverlayView = UIView()
    var backgroundImageOffset = CGPoint()
    var squarePath = UIBezierPath()
    let gridLayer = CALayer()
    
    
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var testImageView: UIImageView!
    
    func createMask() {
        maskOverlayView.frame = self.view.frame
        maskOverlayView.backgroundColor =  UIColor.white.withAlphaComponent(0.6)
        self.view.addSubview(maskOverlayView)
        
        var squareSize = CGFloat()
        let maskLayer = CALayer()
        let squareLayer = CAShapeLayer()
        
        if UIDevice.current.orientation.isLandscape {
            squareSize = self.maskOverlayView.bounds.height - 50
        } else {
            squareSize = self.maskOverlayView.bounds.width - 50
        }
        
        squareLayer.frame = CGRect(x: 0, y: 0, width: maskOverlayView.frame.size.width, height: maskOverlayView.frame.size.height)
        
        let overlay = UIBezierPath(rect: CGRect(x: 0, y: 0, width: maskOverlayView.frame.size.width, height: maskOverlayView.frame.size.height))
    
        squarePath = UIBezierPath(rect: CGRect(x: maskOverlayView.center.x - squareSize / 2, y: maskOverlayView.center.y - squareSize / 2, width: squareSize, height: squareSize))
        
        overlay.append(squarePath.reversing())
        squareLayer.path = overlay.cgPath
        maskLayer.addSublayer(squareLayer)
        
        maskOverlayView.layer.mask = maskLayer
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
    
    @objc func moveImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: maskOverlayView.superview)
        
        //  Saves the position of the background image before pan.
        if sender.state == .began {
            backgroundImageOffset = contentImage.frame.origin
        }
        let position = CGPoint(x: translation.x + backgroundImageOffset.x - contentImage.frame.origin.x, y: translation.y + backgroundImageOffset.y - contentImage.frame.origin.y)
        contentImage.transform = contentImage.transform.translatedBy(x: position.x, y: position.y)
        
        print("Pan!")
    }
    
    @objc func rotateImage(_ sender: UIRotationGestureRecognizer) {
        print("Rotating!")
    }
    
    @objc func scaleImage(_ sender: UIPinchGestureRecognizer) {
        print("Scalling!")
    }
    
    
    
    func configure() {
        maskOverlayView.isUserInteractionEnabled = true
        
        //  MARK: Tap Gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
        maskOverlayView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        
        //  MARK: Pan Gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImage(_:)))
        maskOverlayView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        // MARK: Rotation Gesture
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(_:)))
        maskOverlayView.addGestureRecognizer(rotationGestureRecognizer)
        rotationGestureRecognizer.delegate = self
        
        //  MARK: Pinch Gesture
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        maskOverlayView.addGestureRecognizer(pinchGestureRecognizer)
        pinchGestureRecognizer.delegate = self
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

