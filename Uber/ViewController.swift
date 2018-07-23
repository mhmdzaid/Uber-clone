//
//  ViewController.swift
//  Uber
//
//  Created by mohamed zead on 7/23/18.
//  Copyright © 2018 zead. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var signUpMode = true
    //iboutlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var userSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

    @IBAction func downButtonPressed(_ sender: Any) {
        if signUpMode{
            signUpMode = false
            userSwitch.isHidden = true
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            downButton.setTitle("don't have an account", for: .normal)
            topButton.setTitle("Login ", for: .normal)
        }else{
            signUpMode = true
            userSwitch.isHidden = false
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            downButton.setTitle("have an account !", for: .normal)
            topButton.setTitle("Sign Up", for: .normal)
        }
    }
    
    @IBAction func topButtonPressed(_ sender: Any) {
        if signUpMode{
         
            
        }
        
    }
    

}

