//
//  LoginVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/28/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTxtField: InsetTextField!
    @IBOutlet weak var passwordTxtField: InsetTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        if emailTxtField.text != nil && passwordTxtField.text != nil {
            // login user
            AuthService.instance.loginUser(withEmail: emailTxtField.text!, andPassword: passwordTxtField.text!) { (success, loginError) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(String(describing: loginError?.localizedDescription))
                }
                // if login failed - register user, then log him in
                AuthService.instance.registerUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, userCreationComplete: { (success, registerError) in
                    if success {
                        // THIS PART NOT WORKING!
                        AuthService.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, loginComplete: { (success, nil) in
                            self.dismiss(animated: true, completion: nil)
                            print("Successfull login!")
                        })
                    } else {
                        print(String(describing: registerError?.localizedDescription))
                    }
                })
            }
        }
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LoginVC: UITextFieldDelegate {}
