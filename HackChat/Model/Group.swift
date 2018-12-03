//
//  Group.swift
//  HackChat
//
//  Created by Milan Bojic on 12/3/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import Foundation

class Group {
    private var _groupTitle: String
    private var _groupDescription: String
    private var _groupId: String
    private var _members: [String]
    private var _membersCount: Int

    var title: String {
        return _groupTitle
    }
    var description: String {
        return _groupDescription
    }
    var groupId : String {
        return _groupId
    }
    var members: [String] {
        return _members
    }
    var membersCount: Int {
        return _membersCount
    }
    
    init(title: String, description: String, groupId: String, members: [String], membersCount: Int) {
        self._groupTitle = title
        self._groupDescription = description
        self._groupId = groupId
        self._members = members
        self._membersCount = membersCount
    }
}
