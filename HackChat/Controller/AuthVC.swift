//
//  AuthVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/28/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class AuthVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginByEmailBtnPressed(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        present(loginVC!, animated: true, completion: nil)
    }
    
}
