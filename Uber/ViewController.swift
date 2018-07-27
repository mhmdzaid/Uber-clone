//
//  ViewController.swift
//  Uber
//
//  Created by mohamed zead on 7/23/18.
//  Copyright © 2018 zead. All rights reserved.
//

import UIKit
import FirebaseAuth
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
        
            if emailTextField.text != "" && passwordTextField.text != ""{
                if let email = emailTextField.text {
                    if let password  = passwordTextField.text{
                       if signUpMode{
                               Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil{
                                self.displayAlert("Error", (error?.localizedDescription)!)
                                self.passwordTextField.text = ""
                                self.emailTextField.text = ""
                            }else{
                                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                if self.userSwitch.isOn{
                                    request?.displayName = "Driver"
                                    request?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "toDriverVC", sender: nil)
                                }else{
                                    request?.displayName = "Rider"
                                    request?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier:"toRiderView" , sender: nil)
                                }
                                 // navigate after signing up
                                }
                        })
                       }else{
                        Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error) in
                            if error != nil {
                                self.displayAlert("Error", (error?.localizedDescription)!)
                            }else{
                                if Auth.auth().currentUser?.displayName == "Driver"{
                                   self.performSegue(withIdentifier: "toDriverVC", sender: nil)
                                }else{
                                     self.performSegue(withIdentifier: "toRiderView", sender: nil)
                                }
                                //navigate after login
                            }
                        })
                        }
                        
                    }
                }
            }else{
                self.displayAlert("Missing Fields", "Please Fill out the Fields ")
            }
            
            
        
        
    }
    

}


extension ViewController{
    
    override func viewDidAppear(_ animated: Bool) {
      self.emailTextField.text = ""
      self.passwordTextField.text = ""
    }
    
    func displayAlert(_ title : String , _ message :String ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let Action = UIAlertAction(title: "ok" , style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(Action)
        self.present(alert, animated: true, completion: nil)
    }
}
