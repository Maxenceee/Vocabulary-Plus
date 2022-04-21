//
//  LauchScreenViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 04/04/2021.
//

import UIKit

class LauchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (t) in
            self.performSegue(withIdentifier: "lauchToMain", sender: self)
        }
    }
}
