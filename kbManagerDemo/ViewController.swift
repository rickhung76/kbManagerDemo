//
//  ViewController.swift
//  kbManagerDemo
//
//  Created by 黃柏叡 on 2019/10/21.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import UIKit

class ViewController: FCBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func switchValueChanged(_ sender: UISwitch) {
        KeyboardManager.shared.isEnable = sender.isOn
        print("KeyboardManager KeyboardManager \(sender.isOn)")
    }
}

