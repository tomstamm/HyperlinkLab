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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        linkableText.delegate = self
    }


}
