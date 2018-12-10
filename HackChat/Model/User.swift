//
//  User.swift
//  HackChat
//
//  Created by Milan Bojic on 12/8/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import Foundation
import UIKit

class User {
    private var _email: String
    private var _profile_pic: String
    private var _userId: String
    
    var email: String {
        return _email
    }
    var profile_pic: String {
        return _profile_pic
    }
    var userId: String {
        return _userId
    }
    
    init(email: String, profile_pic: String, userId: String) {
        self._email = email
        self._profile_pic = profile_pic
        self._userId = userId
    }
}
