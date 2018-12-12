//
//  MeVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/29/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        // NOT REFRESHING CHOSEN PICTURE WHEN SET IT FOR THE FIRST TIME !!!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailLbl.text = Auth.auth().currentUser?.email
        DataService.instance.getUser(byUID: (Auth.auth().currentUser?.uid)!) { (returnedUser) in
            // check cache for image first
            if let cachedImage = imageCache.object(forKey: returnedUser.profile_pic as AnyObject) as? UIImage {
                self.profileImg.maskCircle(anyImage: cachedImage)
            }
            // otherwise download images
            let url = URL(string: returnedUser.profile_pic)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: returnedUser.profile_pic as AnyObject)
                            self.profileImg.maskCircle(anyImage: downloadedImage)
                        }
                    }
                }
                }.resume()
        }
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are your sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (buttonPressed) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (buttontapped) in
            self.dismiss(animated: true, completion: nil)
        }
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(cancelAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
    // MARK: - Set profile image
    @IBAction func didTapProfileImg(_ sender: UITapGestureRecognizer) {
        let tappedImg = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: .actionSheet)
        let photoGallery = UIAlertAction(title: "Photos", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        tappedImg.addAction(photoGallery)
        tappedImg.addAction(camera)
        tappedImg.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(tappedImg, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            self.profileImg.maskCircle(anyImage: selectedImage)
            self.uploadImageToStorage()
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Upload image to Firebase
    func uploadImageToStorage() {
        // upload image to storage
        let profilePicStorageRef = DataService.instance.REF_STORAGE.child("user_profiles/\(Auth.auth().currentUser!.uid)/profile_pic.jpeg")
        if let imageData = self.profileImg.image?.jpegData(compressionQuality: 0.5) {
            profilePicStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error == nil {
                    profilePicStorageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error?.localizedDescription ?? "Error while getting download link for image.")
                        } else {
                            // connect image url to user
                            DataService.instance.uploadProfilePicture(forUID: Auth.auth().currentUser!.uid, imageUrl: url!.absoluteString, completion: { (success) in
                                if success {
                                    print("Success, image uploaded to Storage")
                                } else {
                                    print("There was a problem with uploading image to Database!")
                                }
                            })
                        }
                    })
                } else {
                    print(error?.localizedDescription ?? "Error while uploading image to Storage.")
                }
            }
        }
    }
    
    
    
    
}
