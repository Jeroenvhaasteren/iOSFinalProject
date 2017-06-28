//
//  ViewController.swift
//  partage
//
//  Created by Jeroen van Haasteren on 25/05/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database.database().reference()

        
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if let user = Auth.auth().currentUser {
            performSegue(withIdentifier: "LoginToMain", sender: nil)
            print("user: \(user)")
        }
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print("Facebook Error \(error)")
            return
        }
        
        print("isCanceld: \(result.isCancelled)")
        print("declined permissions: \(result.declinedPermissions)")
        print("granted permissions: \(result.grantedPermissions)")
        
        if !result.isCancelled {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential, completion: { (user,error) in
                if let error = error {
                    print("Firebase error \(error)")
                    //self.showMessage(message: "Something went wrong")
                } else {
                    
                    if let user = user {
                        let userInfo = ["uid": user.uid,
                                        "name": user.displayName ?? ""
                        ]
                        self.db.child("users").child(user.uid).setValue(userInfo)
                        self.db.child("users").child(user.uid).child("following").child(user.uid).setValue("true")
                        self.db.child("users").child(user.uid).child("followed").child(user.uid).setValue("true")
                    
                    self.performSegue(withIdentifier: "LoginToMain", sender: nil)
                    }
                }
            })
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginBtnPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passWordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if let user = user {
                    self.performSegue(withIdentifier: "LoginToMain", sender: nil)
                }
            })
        }
    }

}

