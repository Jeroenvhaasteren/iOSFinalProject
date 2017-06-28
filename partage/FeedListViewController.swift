//
//  FeedListViewController.swift
//  partage
//
//  Created by Jeroen van Haasteren on 08/06/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FeedListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var feedtable: UITableView!
    var posts = [Post]()
    var db: DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrievePosts()
    }
    
    func retrievePosts() {
        db.child("posts").queryOrdered(byChild: "timestamp").observe(.value, with:{
        snapshot in
            if let posts = snapshot.value as? [String: [String: Any]] {
                self.posts.removeAll()
                for (_, value) in posts {
                    let post = Post()
                    if let message = value["message"] as? String { post.message = message }
                    if let uid = value["uid"] as? String { post.useruid = uid }
                    if let userName = value["userName"] as? String { post.userName = userName }
                    if let pictureUrl = value["pictureUrl"] as? String { post.pictureUrl = pictureUrl }
                    if let timestamp = value["timestamp"] as? Int {post.timestamp = timestamp}
                    self.posts.append(post)
                }
                self.posts = self.posts.sorted(by: { $0.timestamp > $1.timestamp })
                self.filterPosts()
            }
        })
    }
    
    func filterPosts() {
        if let user = Auth.auth().currentUser {
            db.child("users").child(user.uid).child("following").queryOrderedByKey().observe(.value, with:{
                snapshot in
                var filterSucces: Bool = false
                if let following = snapshot.value as? [String: Bool] {
                    let keys = Array(following.keys)
                    self.posts = self.posts.filter {
                        if let postUserID = $0.useruid {
                            var validation = false
                            for i in 0...keys.count - 1 {
                                if postUserID.contains(keys[i]) && !validation {
                                    validation = true
                                }
                            }
                            return validation
                        } else {
                            return false
                        }
                    }
                    filterSucces = true
                }
                if !filterSucces {
                    self.posts.removeAll()
                }
                self.feedtable.reloadData()
                
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") as! FeedListTableViewCell
        
        let post = posts[indexPath.row]
        
        cell.userName.text = post.userName
        cell.postMessage.text = post.message
        cell.postImageView.image = UIImage()
        cell.postImageView.downloadImage(from: post.pictureUrl!)

        return cell
    }
    
}
