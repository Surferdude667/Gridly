//
//  GameController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 18/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GameController: UIViewController {
    
    @IBOutlet var tiles: [UIImageView]!
    @IBOutlet var positions: [UIImageView]!
    
    func configure() {
        tiles.shuffle()
        addTilesToViews()
        fitViews()
    }
    
    func addTilesToViews() {
        for i in 0..<tiles.count {
            tiles[i].image = Tile.pieces[i].tileImage
            tiles[i].tag = Tile.pieces[i].id
            Tile.pieces[i].originalPosition = tiles[i].frame.origin
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
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
        } else {
            //  Tile placed wrong
            if positionID != nil {
                moveView(view: tiles[viewID], position: positions[positionID!].frame.origin)
            } else {
                //  Tile is not placed near any position
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
