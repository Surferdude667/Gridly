//
//  ViewController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 09/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GameController: UIViewController, UIGestureRecognizerDelegate {
    
    let maskOverlayView = UIView()
    let preGameControlsView = UIView()
    var contentImageOffset = CGPoint()
    var squarePath = UIBezierPath()
    let gridLayer = CALayer()
    var moveCount = 0
    var previewUsed = false
    
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet var puzzleDestinations: [UIImageView]!
    @IBOutlet var puzzleTiles: [UIImageView]!
    @IBOutlet var puzzleStacks: [UIImageView]!
    @IBOutlet weak var moveCountLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var startGameButton: UIButton!
    
    func configure() {
        blurView.effect = nil
        Tile.shared.removeAll()
        configureTapGestures()
    }
    
    
    func createMask() {
        maskOverlayView.frame = self.view.frame
        maskOverlayView.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(maskOverlayView)
        
        var squareSize = CGFloat()
        let maskLayer = CALayer()
        let squareLayer = CAShapeLayer()
        
        
        //  Check device and orintation to adjust mask size
        //  All other UI elements adjusts itself based on maske size
        if UIDevice.current.orientation.isLandscape {
            
            //  iPad Landscape
            if UIDevice.current.userInterfaceIdiom == .pad {
                squareSize = maskOverlayView.bounds.height - 250
            }
            
            //  iPhone Landscape
            if UIDevice.current.userInterfaceIdiom == .phone {
                squareSize = maskOverlayView.bounds.height - 50
            }
            
        } else if UIDevice.current.orientation.isPortrait {
            
            //  iPad Portrait
            if UIDevice.current.userInterfaceIdiom == .pad {
                squareSize = maskOverlayView.bounds.width - 200
            }
            
            //  iPhone Portrait
            if UIDevice.current.userInterfaceIdiom == .phone {
                squareSize = maskOverlayView.bounds.width - 50
            }
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
    
    
    func createPuzzle() {
        print("Loading...")
        renderPuzzleImage()
        renderPuzzleTiles()
        addTilesToViews()
        GameHelper.fitViews(views: puzzleTiles, startPosition: CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y), offset: squarePath.bounds.width / 4)
        animateTilesToStack()
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
        preGameControlsView.isUserInteractionEnabled = true
        
        //  MARK: Tap Gesture
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(createPuzzle(_:)))
//        maskOverlayView.addGestureRecognizer(tapGestureRecognizer)
//        tapGestureRecognizer.delegate = self
        
        //  MARK: Pan Gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImage(_:)))
        preGameControlsView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        // MARK: Rotation Gesture
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(_:)))
        preGameControlsView.addGestureRecognizer(rotationGestureRecognizer)
        rotationGestureRecognizer.delegate = self
        
        //  MARK: Pinch Gesture
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        preGameControlsView.addGestureRecognizer(pinchGestureRecognizer)
        pinchGestureRecognizer.delegate = self
    }
    
    
    func bringViewsToTop() {
        preGameControlsView.frame = self.view.frame
        self.view.addSubview(preGameControlsView)
        preGameControlsView.addSubview(startGameButton)
        preGameControlsView.addSubview(infoLabel)
        
        //self.blurView.bringSubviewToFront(startGameButton)
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
                
                Tile.shared.append(Tile(id: tileId, tileImage: tile, correctlyPlaced: false, puzzlePosition: nil, oldTag: nil))
                xOffset += offsetCalculation
                tileId += 1
            }
            xOffset = 0.0
            yOffset += offsetCalculation
        }
    }
    
    
    func animateToGame() {
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
            self.maskOverlayView.alpha = 0.0
            self.gridLayer.opacity = 0.0
            self.preGameControlsView.alpha = 0.0
        }) { (success) in
            UIView.animate(withDuration: 1.0) {
                self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                self.gridLayer.opacity = 0.5
                self.gridLayer.frame.origin = CGPoint(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y)
                self.maskOverlayView.isHidden = true
                self.preGameControlsView.isHidden = true
                
                for element in self.puzzleDestinations {
                    element.backgroundColor = UIColor.black
                    element.alpha = 0.5
                }
            }
        }
    }
    
    func addTilesToViews() {
        //  Assign tags to puzzleStacks
        for i in 0..<puzzleTiles.count {
            puzzleStacks[i].tag = i
        }
        
        puzzleStacks.shuffle()
        
        for i in 0..<puzzleTiles.count {
            puzzleTiles[i].image = Tile.shared[i].tileImage
            puzzleTiles[i].tag = Tile.shared[i].id
            Tile.shared[i].stackPairID = puzzleStacks[i].tag
        }
    }
    
    
    func animateTilesToStack() {
        print("Loading completed!")
        for i in 0..<puzzleTiles.count {
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: [], animations: {
                self.puzzleTiles[i].bounds.size = self.puzzleStacks[i].bounds.size
                GameHelper.moveView(view: self.puzzleTiles[i], to: self.puzzleStacks[i].frame.origin)
            }) { (success) in
                self.updateViewPositions()
            }
        }
        animateToGame()
    }
    
    
    func validatePlacement(viewID: Int, positionID: Int?) {
        //  Tile placed correctley
        if viewID == positionID {
            GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleDestinations[positionID!].frame.origin)
            Tile.shared[viewID].correctlyPlaced = true
            Tile.shared[viewID].puzzlePositionInGrid = positionID
            moveCount += 1
            moveCountLabel.text = "\(moveCount)"
        } else {
            //  Tile placed wrong
            if positionID != nil {
                Tile.shared[viewID].correctlyPlaced = false
                Tile.shared[viewID].puzzlePositionInGrid = positionID
                GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleDestinations[positionID!].frame.origin)
                moveCount += 1
                moveCountLabel.text = "\(moveCount)"
            } else {
                //  Tile is not placed near any position
                Tile.shared[viewID].correctlyPlaced = false
                Tile.shared[viewID].puzzlePositionInGrid = nil
                
                if let originalPosition = Tile.shared[viewID].stackPairID {
                    puzzleTiles[viewID].bounds.size = puzzleStacks[0].bounds.size
                    GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleStacks[originalPosition].frame.origin)
                }
            }
        }
        checkGameStatus()
    }
    
    func updateViewPositions() {
        GameHelper.fitViews(views: puzzleDestinations, startPosition: CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y), offset: squarePath.bounds.width / 4)
        
        
        if UIDevice.current.orientation.isLandscape {
            positionPuzzleStacks(rows: 8.0, startPosition: CGPoint(x: squarePath.bounds.origin.x + squarePath.bounds.width + 10, y: squarePath.bounds.origin.y))
        } else if UIDevice.current.orientation.isPortrait {
            positionPuzzleStacks(rows: 2.0, startPosition: CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y + squarePath.bounds.height + 10))
        }
        
        for i in 0..<Tile.shared.count {
            if Tile.shared[i].puzzlePositionInGrid != nil {
                let ID = Tile.shared[i].puzzlePositionInGrid
                puzzleTiles[i].bounds.size = CGSize(width: squarePath.bounds.width / 4, height: squarePath.bounds.height / 4)
                GameHelper.moveView(view: puzzleTiles[i], to: puzzleDestinations[ID!].frame.origin)
            } else {
                puzzleTiles[i].bounds.size = puzzleStacks[i].bounds.size
                
                if let originalPosition = Tile.shared[i].stackPairID {
                    GameHelper.moveView(view: puzzleTiles[i], to: puzzleStacks![originalPosition].frame.origin)
                }
            }
        }
        
    }
    
    
    func positionPuzzleStacks(rows: CGFloat, startPosition: CGPoint) {
        let seats: CGFloat = CGFloat(Int(puzzleStacks.count))
        var spacing: CGFloat = 5.0
        let calculatedSpacing = (spacing * (seats / 2 - 1) / (seats / 2))
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
        
        let size = CGSize(width: squarePath.bounds.width / (seats / 2) - calculatedSpacing, height: squarePath.bounds.height / (seats / 2) - calculatedSpacing)
        
        var i = 0
        for _ in 0..<Int(CGFloat(rows)) {
            spacing = 0.0
            for _ in 0..<Int(CGFloat(seats / rows)) {
                puzzleStacks[i].bounds.size = size
                puzzleStacks[i].frame.origin = CGPoint(x: startPosition.x + xOffset + spacing, y: startPosition.y + yOffset)
                
                xOffset += puzzleStacks[i].bounds.width + spacing
                spacing = 5.0
                i += 1
            }
            xOffset = 0.0
            yOffset += puzzleStacks[0].bounds.height + spacing
        }
    }
    
    func positionPreGameElements() {
        
        //  Check device and orintation to adjust mask size
        //  All other UI elements adjusts itself based on maske size
        if UIDevice.current.orientation.isLandscape {
            
            //  iPad Landscape
            if UIDevice.current.userInterfaceIdiom == .pad {
                infoLabel.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - infoLabel.bounds.width / 2
                infoLabel.frame.origin.y = squarePath.bounds.origin.y - 50
                
                startGameButton.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - startGameButton.bounds.width / 2
                startGameButton.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height + 30
                
            }
            
            //  iPhone Landscape
            if UIDevice.current.userInterfaceIdiom == .phone {
                infoLabel.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - infoLabel.bounds.width / 2
                infoLabel.frame.origin.y = squarePath.bounds.origin.y - 50
                
            }
            
        } else if UIDevice.current.orientation.isPortrait {
            
            //  iPad Portrait
            if UIDevice.current.userInterfaceIdiom == .pad {
                infoLabel.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - infoLabel.bounds.width / 2
                infoLabel.frame.origin.y = squarePath.bounds.origin.y - 50
                
                startGameButton.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - startGameButton.bounds.width / 2
                startGameButton.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height + 30
            }
            
            //  iPhone Portrait
            if UIDevice.current.userInterfaceIdiom == .phone {
                infoLabel.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - infoLabel.bounds.width / 2
                infoLabel.frame.origin.y = squarePath.bounds.origin.y - 50
                
                startGameButton.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - startGameButton.bounds.width / 2
                startGameButton.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height + 30
            }
        }
        
    }
    
    
    func preview() {
        for i in 0..<Tile.shared.count {
            
            if previewUsed == false {

                //  Move pieces to correct place
                if Tile.shared[i].correctlyPlaced == false && Tile.shared[i].puzzlePositionInGrid != nil {
                    GameHelper.moveView(view: puzzleTiles[i], to: puzzleDestinations[i].frame.origin)
                } else if Tile.shared[i].puzzlePositionInGrid == nil {
                    puzzleTiles[i].bounds.size = puzzleDestinations[i].bounds.size
                    GameHelper.moveView(view: puzzleTiles[i], to: puzzleDestinations[i].frame.origin)
                }
                
                //  Move pieces back after 2 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if Tile.shared[i].correctlyPlaced == false && Tile.shared[i].puzzlePositionInGrid != nil {
                        GameHelper.moveView(view: self.puzzleTiles[i], to: self.puzzleDestinations[Tile.shared[i].puzzlePositionInGrid!].frame.origin)
                    } else if Tile.shared[i].puzzlePositionInGrid == nil {
                        self.puzzleTiles[i].bounds.size = self.puzzleStacks[i].bounds.size
                        GameHelper.moveView(view: self.puzzleTiles[i], to: self.puzzleStacks[Tile.shared[i].stackPairID!].frame.origin)
                    }
                }
            }
        }
        previewUsed = true
    }
    
    
    func checkGameStatus() {
        var correctAnswers = 0
        
        for element in Tile.shared {
            if element.correctlyPlaced {
                correctAnswers += 1
            }
        }
        
        if correctAnswers == Tile.shared.count {
            print("Game completed!")
            gridLayer.isHidden = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @objc func refreshUI() {
        createMask()
        drawGrid()
        updateViewPositions()
        bringViewsToTop()
        positionPreGameElements()
    }
    
    override func viewDidLayoutSubviews() {
        refreshUI()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: UIApplication.willEnterForegroundNotification, object: nil)
//    }
    
    
    
    @IBAction func moveTileWithPan(_ recognizer: UIPanGestureRecognizer) {
        
        guard let recognizerView = recognizer.view else {
            return
        }
        
        let translation = recognizer.translation(in: view)
        recognizerView.center.x += translation.x
        recognizerView.center.y += translation.y
        recognizer.setTranslation(.zero, in: view)
        
        var positionID: Int?
        
        for position in puzzleDestinations {
            let tileDistance = GameHelper.calculateDistance(recognizerView.frame.origin, position.frame.origin)
            
            if 0...40 ~= tileDistance {
                position.backgroundColor = UIColor.white
                position.alpha = 0.8
                positionID = puzzleDestinations.firstIndex(of: position)
            } else {
                position.backgroundColor = UIColor.black
                position.alpha = 0.5
            }
        }
        
        switch recognizer.state {
        case .ended:
            validatePlacement(viewID: recognizerView.tag, positionID: positionID)
        case .began:
            UIView.animate(withDuration: 0.3) {
                recognizerView.bounds.size = CGSize(width: self.squarePath.bounds.width / 4, height: self.squarePath.bounds.height / 4)
            }
        default:
            return
        }
    }
    
    @IBAction func previewButton(_ sender: Any) {
        preview()
    }
    
    @IBAction func newGameButton(_ sender: Any) {
    }
    
    @IBAction func startGameButton(_ sender: Any) {
        createPuzzle()
    }
}
