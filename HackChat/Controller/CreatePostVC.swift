//
//  CreatePostVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/29/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

class CreatePostVC: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        sendBtn.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailLbl.text = Auth.auth().currentUser?.email
        
        DataService.instance.getUser(byUID: (Auth.auth().currentUser?.uid)!) { (returnedUser) in
            // check cache for image first
            if let cachedImage = imageCache.object(forKey: returnedUser.profile_pic as AnyObject) as? UIImage {
                self.userImage.maskCircle(anyImage: cachedImage)
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
                            self.userImage.maskCircle(anyImage: downloadedImage)
                        }
                    }
                }
                }.resume()
        }
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        if textView.text != "" && textView.text != "Say something here..." {
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: textView.text, userID: (Auth.auth().currentUser?.uid)!, withGroupKey: nil) { (success) in
                if success {
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.sendBtn.isEnabled = true
                    print("There has been error uploading your post.")
                }
            }
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension CreatePostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}
