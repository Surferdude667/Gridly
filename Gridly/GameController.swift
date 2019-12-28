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
    
    func validatePlacement(viewID: Int, positionID: Int?) {
        if viewID == positionID {
            print("Correctley placed!")
            moveView(view: tiles[viewID], position: positions[positionID!].frame.origin)
        } else {
            if positionID != nil {
                print("Wrong placed!")
                moveView(view: tiles[viewID], position: positions[positionID!].frame.origin)
            } else {
                print("Nil!")
                moveView(view: tiles[viewID], position: Tile.pieces[viewID].originalPosition!)
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
