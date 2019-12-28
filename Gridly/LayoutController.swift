//
//  ViewController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 09/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class LayoutController: UIViewController, UIGestureRecognizerDelegate {
    
    let maskOverlayView = UIView()
    var contentImageOffset = CGPoint()
    var squarePath = UIBezierPath()
    let gridLayer = CALayer()
    
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet var positions: [UIImageView]!
    @IBOutlet var tiles: [UIImageView]!
    
    func setup() {
        blurView.effect = nil
        Tile.pieces.removeAll()
        configureTapGestures()
    }
    
    func createMask() {
        maskOverlayView.frame = self.view.frame
        maskOverlayView.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
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
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
    
    
    @objc func changeImage(_ sender: Any) {
        renderPuzzleImage()
        renderPuzzleTiles()
        movePuzzle()
        configure()
        bringViewsToTop()
        //performSegue(withIdentifier: "gameSegue", sender: self)
    }
    
    
    //  TODO: Flicker problem on to much zoom.
    @objc func moveImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: contentImage.superview)
        
        //  Saves the position of the background image before pan.
        if sender.state == .began {
            contentImageOffset = contentImage.frame.origin
        }
        
        let position = CGPoint(x: translation.x + contentImageOffset.x - contentImage.frame.origin.x, y: translation.y + contentImageOffset.y - contentImage.frame.origin.y)
        
        contentImage.transform = contentImage.transform.translatedBy(x: position.x, y: position.y)
    }
    
    //  TODO: Rotates from the middle now...
    @objc func rotateImage(_ sender: UIRotationGestureRecognizer) {
        contentImage.transform = contentImage.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    //  TODO: Scales from the middle of image now...
    @objc func scaleImage(_ sender: UIPinchGestureRecognizer) {
        contentImage.transform = contentImage.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    
    func configureTapGestures() {
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
        self.view.bringSubviewToFront(positions[0])
    }
    
    
    func renderPuzzleImage() {
        let renderer = UIGraphicsImageRenderer(bounds: squarePath.bounds)
        let image = renderer.image { (context) in
            gridLayer.isHidden = true
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        Tile.image = image
        gridLayer.isHidden = false
    }
    

    func renderPuzzleTiles() {
        var tileId = 0
        var yOffset: CGFloat = 0.0
        var xOffset: CGFloat = 0.0
        let offsetCalculation = squarePath.bounds.width / 4
        
        for _ in 0..<4 {
            for _ in 0..<4 {
                let tileSize = CGRect(x: squarePath.bounds.origin.x + xOffset, y: squarePath.bounds.origin.y + yOffset, width: squarePath.bounds.width / 4, height: squarePath.bounds.height / 4)
                let tileRendere = UIGraphicsImageRenderer(bounds: tileSize)
                
                let tile = tileRendere.image { (contex) in
                    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
                }
    
                Tile.pieces.append(Tile(id: tileId, tileImage: tile, originalPosition: nil))
                xOffset += offsetCalculation
                tileId += 1
            }
            xOffset = 0.0
            yOffset += offsetCalculation
        }
    }
    

    
    func movePuzzle() {
        UIView.animate(withDuration: 1.0) {
            self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.maskOverlayView.isHidden = true
            self.gridLayer.frame.origin = CGPoint(x: 0.0, y: -200.0)
            self.gridLayer.opacity = 0.4
            print(self.gridLayer.frame.width)
        }
    }
    
    override func viewDidLayoutSubviews() {
        createMask()
        drawGrid()
        bringViewsToTop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    //  ------------ FROM GAME VIEWCONTROLLER
    
    func configure() {
        tiles.shuffle()
        addTilesToViews()
        //fitViews()
    }
    
    func addTilesToViews() {
        for i in 0..<tiles.count {
            tiles[i].image = Tile.pieces[i].tileImage
            tiles[i].tag = Tile.pieces[i].id
            Tile.pieces[i].originalPosition = tiles[i].frame.origin
        }
    }
    
    
    func calculateDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func moveView(view: UIImageView, position: CGPoint) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            view.frame.origin = position
        }) { (success) in
            print("Done animating!")
        }
    }
    
    func fitViews() {
        var yOffset: CGFloat = 0.0
        var xOffset: CGFloat = 0.0
        let offsetCalculation = view.bounds.width / 4
        var counter = 0
        
        let startPosition = CGPoint(x: 0.0, y: 0.0)
        
        
        for _ in 0..<4 {
            for _ in 0..<4 {
                let positionSize = CGRect(x: startPosition.x + xOffset, y: startPosition.y + yOffset, width: view.bounds.width / 4, height: view.bounds.width / 4)
                
                positions[counter].frame = positionSize
                
                xOffset += offsetCalculation
                counter += 1
            }
            xOffset = 0.0
            yOffset += offsetCalculation
        }
    }
    
    
    func validatePlacement(viewID: Int, positionID: Int?) {
        //  Tile placed correctley
        if viewID == positionID {
            moveView(view: tiles[viewID], position: positions[positionID!].frame.origin)
            print("Correct!")
        } else {
            //  Tile placed wrong
            if positionID != nil {
                print("Wrong!")
                moveView(view: tiles[viewID], position: positions[positionID!].frame.origin)
            } else {
                //  Tile is not placed near any position
                print("Outside")
                if let originalPostion = Tile.pieces[viewID].originalPosition {
                    moveView(view: tiles[viewID], position: originalPostion)
                }
            }
        }
    }
    
    
    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view else {
            return
        }
        
        let translation = recognizer.translation(in: view)
        recognizerView.center.x += translation.x
        recognizerView.center.y += translation.y
        recognizer.setTranslation(.zero, in: view)
        
        var positionID: Int?
        
        for position in positions {
            let tileDistance = calculateDistance(recognizerView.frame.origin, position.frame.origin)
            
            if 0...20 ~= tileDistance {
                position.backgroundColor = UIColor.black
                positionID = positions.firstIndex(of: position)
            } else {
                position.backgroundColor = UIColor.gray
            }
        }
        
        if recognizer.state == .ended {
            validatePlacement(viewID: recognizerView.tag, positionID: positionID)
        }
    }
    
    
}
