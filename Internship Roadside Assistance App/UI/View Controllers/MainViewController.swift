//
//  MainViewController.swift
//  Roadside Assistance Application
//
//  Created by Ken-Chi Huang on 13/03/2020.
//  Copyright © 2020 Ken-Chi Huang. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var privacyPolicyButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func openPrivacyPolicy(_ sender: UIButton) {
        createAlert();
    }
    
    func createAlert(){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: "To use this app, you must accept the privacy policy.", message: "", preferredStyle: .alert)
            // Action to allow user to go to settings with a response to the alert
            let openPrivacyAction = UIAlertAction( title: "Privacy Policy", style: .default, handler: { _ in
                    guard let url = URL(string: "about:blank") else { return }
                    UIApplication.shared.open(url) })
            // Action to allow user to close alert pop up
            let acceptAction = UIAlertAction( title: "Accept", style: .default, handler: { _ in } )
            
            // Adds both actions to the alert pane
            alert.addAction(acceptAction)
            alert.addAction(openPrivacyAction)
            
            // Enables the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

