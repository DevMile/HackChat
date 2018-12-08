//
//  AuthService.swift
//  HackChat
//
//  Created by Milan Bojic on 11/28/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    static let instance = AuthService()
    
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            let defaultProfileImageUrl = "https://firebasestorage.googleapis.com/v0/b/hackchat-300a0.appspot.com/o/defaultProfileImage.png?alt=media&token=0a12fe97-9818-458b-b025-dbb871f1a9da"
            let userData = ["provider": user.user.providerID, "email": user.user.email, "profile_pic": defaultProfileImageUrl]
            DataService.instance.createDBUser(userId: user.user.uid, userData: userData as Dictionary<String, Any>)
            userCreationComplete(true, nil)
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                loginComplete(false, error)
            }
            loginComplete(true, nil)
        }
    }
    
    
}
