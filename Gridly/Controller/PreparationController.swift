//
//  PreparationController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 07/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class PreparationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome")
    }
    
    @IBAction func startButton(_ sender: Any) {
        performSegue(withIdentifier: "toGameSegue", sender: self)
    }
    
}
