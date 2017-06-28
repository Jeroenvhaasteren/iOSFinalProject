//
//  UserListViewController.swift
//  partage
//
//  Created by Jeroen van Haasteren on 01/06/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserListTableViewCellDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var db: DatabaseReference!
    var filterdUsers = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        db = Database.database().reference()
        
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        retrieveUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterdUsers = users.filter { user in
            if let name = user.name {
                return name.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
            return false
        }
        tableView.reloadData()
    }
    
    func retrieveUsers() {
        db.child("users").queryOrderedByKey().observe(.value, with: { snapshot in
            if let users = snapshot.value as? [String: [String: Any]] {
                self.users.removeAll()
                for (_, value) in users {
                    let user = User()
                    if let uid = value["uid"] as? String { user.uid = uid }
                    if let name = value["name"] as? String { user.name = name }
                    if let followed = value["followed"] as? [String: Bool] {
                        print("Found followed")
                        if let currentUser = Auth.auth().currentUser?.uid {
                            if let isFollowed = followed[currentUser] {
                                user.follow = isFollowed
                            }
                        }
                    }
                    self.users.append(user)
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterdUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserListTableViewCell
        let user: User
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterdUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.nameLabel.text = user.name
        cell.selectionStyle = .none
        cell.delegate = self
        if user.follow {
            cell.followButton.setTitle("Unfollow", for: .normal)
        } else {
            cell.followButton.setTitle("Follow", for: .normal)
        }
        return cell
    }
    
    func userCellFollowButtonPressed(sender: UserListTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let user: User
            if searchController.isActive && searchController.searchBar.text != "" {
                user = filterdUsers[indexPath.row]
            } else {
                user = users[indexPath.row]
            }
            if(!user.follow) {
                if let currentUser = Auth.auth().currentUser {
                  self.db.child("users").child(currentUser.uid).child("following").child(user.uid!).setValue(true)
                    self.db.child("users").child(user.uid!).child("followed").child(currentUser.uid).setValue(true)
                }
            } else {
                if let currentUser = Auth.auth().currentUser {
                    self.db.child("users").child(currentUser.uid).child("following").child(user.uid!).removeValue()
                    self.db.child("users").child(user.uid!).child("followed").child(currentUser.uid).removeValue()
                }
            }
            user.follow = !user.follow
            tableView.reloadData()
        }
    }
}
