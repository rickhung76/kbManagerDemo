//
//  ViewController.swift
//  kbManagerDemo
//
//  Created by 黃柏叡 on 2019/10/21.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import UIKit

class ViewController: FCBaseViewController {
    
    @IBOutlet weak var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        kbClickGoClosure = { (_) in
            print(#file, #function)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    @IBAction func switchValueChanged(_ sender: UISwitch) {
        KeyboardManager.shared.isEnable = sender.isOn
        print("KeyboardManager KeyboardManager \(sender.isOn)")
    }
}

