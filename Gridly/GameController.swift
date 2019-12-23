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
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        
        checkIntercetion()
        //let check = distance(image1.frame.origin, place1.frame.origin)
        //print(check)
    }
    

    
    
    func checkIntercetion() {
//        if image1.frame.intersects(place1.frame) {
//            print("They touch!")
//        } else {
//            print("They don't touch!")
//        }
    }
    
    func calculateDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
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
            
            if 0...15 ~= tileDistance {
                position.backgroundColor = UIColor.black
                positionID = positions.firstIndex(of: position)
            } else {
                position.backgroundColor = UIColor.gray
            }
        }
        
//        func bringViewsToTop() {
//            self.view.bringSubviewToFront(positions)
//        }
        
        if recognizer.state == .ended {
            //print("Ended!")
            print("Position: \(positionID!)")
            
            if recognizerView.tag == positionID {
                print("Correctley placed!")
            } else {
                print("Wrong!")
            }
            
        }
        
    }
    
}
