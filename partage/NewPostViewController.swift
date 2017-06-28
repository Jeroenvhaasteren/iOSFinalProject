//
//  NewPostViewController.swift
//  partage
//
//  Created by Jeroen van Haasteren on 30/05/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //DECLARATIONS
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postMessage: UITextField!
    
    var imgPicker = UIImagePickerController()
    var db: DatabaseReference!
    var userStorage: StorageReference!
    
    //METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://partage-49ebd.appspot.com/")
        userStorage = storage.child("pictures")
        imgPicker.delegate = self
        postMessage.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnASelectImage(_ sender: UIButton) {
        let alertViewController = UIAlertController(title: "Add image", message: "You want to take a picture or select one?", preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Choose from gallery", style: .default, handler: {action in self.openGallery()})
        
        let cameraAction = UIAlertAction(title: "Take a picture", style: .default, handler: {action in self.openCamera()})
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {action in print("Cancel")})
        
        alertViewController.addAction(galleryAction)
        alertViewController.addAction(cameraAction)
        alertViewController.addAction(cancelAction)
        
        present(alertViewController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imgPicker.sourceType = .camera
            imgPicker.cameraDevice = .front
            present(imgPicker, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imgPicker.dismiss(animated: true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.postImage.image = image
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        
    }

    @IBAction func btnUploadNewPost(_ sender: UIButton) {
        if let image = self.postImage.image {
            // UPLOAD PIC TO STORAGE
            // get jpg representation from image
            let jpeg = UIImageJPEGRepresentation(image, 0.8)
            // generate a name for my new image to be uploaded
            let name = self.db.child("pictures").childByAutoId().key
            // create a reference for the image to be uploaded
            let imageRef = self.userStorage.child("\(name).jpg")
            // create an async task to upload the image
            let uploadTask = imageRef.putData(jpeg!, metadata: nil, completion: { (metadata, error) in
                // when the upload finishes, get a url to the image on storage
                imageRef.downloadURL(completion: { (url, error) in
                    // save the url on the database
                    self.db.child("pictures").child(name).setValue(["url": url?.absoluteURL.absoluteString])
                    
                    let idPost = self.db.child("posts").childByAutoId().key
                    if let user = Auth.auth().currentUser {
                        self.db.child("posts").child(idPost).setValue(["pictureUrl": url?.absoluteURL.absoluteString, "uid": user.uid , "message": self.postMessage.text, "userName": user.displayName, "timestamp": ServerValue.timestamp()])
                        self.resetPostForm()
                        self.tabBarController?.selectedIndex = 2
                    }
                })
            })
            // start uploading
            uploadTask.resume()
        }
    }
    
    func resetPostForm() {
        self.postMessage.text = ""
        self.postImage.image = UIImage(named: "1024px-No_image_available.svg")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        postMessage.resignFirstResponder()
        return true
    }


}
