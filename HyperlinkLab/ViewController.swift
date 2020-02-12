//
//  ViewController.swift
//  HyperlinkLab
//
//  Created by wizard on 2/6/20.
//  Copyright © 2020 wizard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var linkableText: LinkableUITextView!
    @IBOutlet var enabledSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkableText.delegate = self
        enabledSwitch.isOn = linkableText.enabled
    }

    @IBAction func enableSwitchChanged(_ sender: UISwitch) {
        linkableText.enabled = sender.isOn
    }
}
