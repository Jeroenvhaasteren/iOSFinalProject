//
//  ProfileViewController.swift
//  partage
//
//  Created by Jeroen van Haasteren on 08/06/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var textViewFullName: UILabel!
    @IBOutlet weak var textViewFollowing: UILabel!
    @IBOutlet weak var textViewFollowed: UILabel!
    
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference()
        // Do any additional setup after loading the view.
        getFullName()
        getFollowers()
        getFollowing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFullName() {
        if let user = Auth.auth().currentUser {
            textViewFullName.text = user.displayName
        }
    }
    
    func getFollowing() {
        if let user = Auth.auth().currentUser {
            db.child("users").child(user.uid).child("following").queryOrderedByKey().observe(.value, with:{
                snapshot in
                if let following = snapshot.childrenCount as? UInt {
                    self.textViewFollowing.text = String(following)
                }
            })
        }
    }
    
    func getFollowers() {
        if let user = Auth.auth().currentUser {
            db.child("users").child(user.uid).child("followed").queryOrderedByKey().observe(.value, with:{
                snapshot in
                if let followers = snapshot.childrenCount as? UInt {
                    self.textViewFollowed.text = String(followers)
                }
            })
        }
    }
    
    @IBAction func LogOutBtnPressed(_ sender: UIButton) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        do {
            try Auth.auth().signOut()
            FBSDKAccessToken.setCurrent(nil)
        } catch {
            
        }
    }
}
