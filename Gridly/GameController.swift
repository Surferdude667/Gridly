//
//  GameController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 18/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GameController: UIViewController {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var place1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIntercetion()
    }
    
    
    //  Check which place it's closest to and need to check.
    func checkIntercetion() {
        if image1.frame.intersects(place1.frame) {
            print("They touch!")
        } else {
            print("They don't touch!")
        }
    }

}
