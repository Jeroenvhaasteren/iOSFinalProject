//
//  RegisterViewController.swift
//  partage
//
//  Created by Jeroen van Haasteren on 29/05/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var db: DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        if validatePassword() {
            if let email = emailTextField.text, let password = passwordTextField.text {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let user = user {
                        
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = self.nameTextField.text ?? ""
                        changeRequest.commitChanges(completion: nil)
                        
                        let userInfo = ["uid": user.uid,
                                        "name": self.nameTextField.text ?? ""
                        ]
                        self.db.child("users").child(user.uid).setValue(userInfo)

                        self.performSegue(withIdentifier: "registerToMain", sender: nil)
                        
                    } else {
                        self.showMessage(message: NSLocalizedString("Something went wrong", comment: ""))
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    func validatePassword() -> Bool {
        var validation = false
        if let passwordText = passwordTextField.text {
            if let confirmPasswordText = confirmPasswordTextField.text {
                if passwordText == confirmPasswordText {
                    if passwordText.characters.count > 5 {
                        validation = true
                    } else {
                        validation = false
                        showMessage(message: "Password should be at least 6 characters")
                    }
                } else {
                    validation = false
                    showMessage(message: "The passwords do not match")
                }
            }
        }
        return validation
    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    


}
