//
//  Message.swift
//  HackChat
//
//  Created by Milan Bojic on 11/30/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import Foundation

class Message {
    private var _content: String
    private var _senderId: String
    
    var content: String {
        return _content
    }
    var senderId: String {
        return _senderId
    }
    
    init(content: String, senderId: String) {
        self._content = content
        self._senderId = senderId
    }
}
