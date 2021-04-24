//
//  MapCallViewController.swift
//  Roadside Assistance Application
//
//  Created by Ken-Chi Huang on 07/03/2020.
//  Copyright © 2020 Ken-Chi Huang. All rights reserved.
//

import UIKit

class MapCallViewController: UIViewController {
    // Outlets
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callLabel: UIButton!
    
    // View Controller functionality
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Function to dial a number - in this case, this would be to call a help line
    @IBAction func callFunction(_ sender: UIButton) {
        let callURL = URL(string: "tel://\(+123456789)")
        if(UIApplication.shared.canOpenURL(callURL!)){
            UIApplication.shared.open(callURL!)
        } else { return }
    }
}
