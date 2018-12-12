//
//  AuthVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/28/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

class AuthVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func loginByEmailBtnPressed(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
    }
    
    @IBAction func loginWithGoogle(_ sender: Any) {
    }
    
}
