//
//  Tiles.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 18/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation
import UIKit

class Tile {
    let id: Int
    let tileImage: UIImage
    var originalPosition: CGPoint?
    var correctlyPlaced: Bool
    var puzzlePosition: Int?
    
    static var image: UIImage?
    static var pieces = [Tile]()
    
    init(id: Int, tileImage: UIImage, originalPosition: CGPoint?, correctlyPlaced: Bool, puzzlePosition: Int?) {
        self.id = id
        self.tileImage = tileImage
        self.originalPosition = originalPosition
        self.correctlyPlaced = correctlyPlaced
        self.puzzlePosition = puzzlePosition
    }
}
