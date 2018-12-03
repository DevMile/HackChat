//
//  DataService.swift
//  HackChat
//
//  Created by Milan Bojic on 11/27/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
    
    func createDBUser(userId: String, userData: Dictionary<String,Any>) {
        REF_USERS.child(userId).updateChildValues(userData)
    }
    
    func uploadPost(withMessage message: String, userID uid: String, withGroupKey groupKey: String?, sendComplete: @escaping (_ status: Bool) -> ()) {
        if groupKey != nil {
            // send post to groups
        } else {
            // send post to feed
            REF_FEED.childByAutoId().updateChildValues(["content": message, "senderId": uid])
            sendComplete(true)
        }
    }
    
    func getFeedMessages(handler: @escaping (_ messages: [Message]) -> ()) {
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for message in feedMessageSnapshot {
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                let message = Message(content: content, senderId: senderId)
                messageArray.append(message)
            }
            handler(messageArray)
        }
    }
    
    func getUsername(forUID uid: String, handler: @escaping (_ username: String) -> ()) {
        let query = REF_USERS.child(uid)
        query.observeSingleEvent(of: .value) { (userSnapshot) in
            handler(userSnapshot.childSnapshot(forPath: "email").value as! String)
        }
        //        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
        //            guard let user = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
        //            for username in user {
        //                if username.key == uid {
        //                    handler(username.childSnapshot(forPath: "email").value as! String)
        //                }
        //            }
        //        }
    }
    
    func getEmails(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if email.contains(query) && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func getIds(forUsernames usernames: [String], handler: @escaping (_ uidArray: [String]) -> ()) {
        var idArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                if usernames.contains(email) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func createGroup(withTitle title: String, andDescription description: String, forUserIds userIds: [String], completion: @escaping (_ success: Bool) -> ()) {
        REF_GROUPS.childByAutoId().updateChildValues(["title": title, "description": description, "members": userIds])
        completion(true)
    }
    
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (groupsSnapshot) in
            guard let groups = groupsSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for group in groups {
                let membersArray = group.childSnapshot(forPath: "members").value as! [String]
                if membersArray.contains(Auth.auth().currentUser!.uid) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let description = group.childSnapshot(forPath: "description").value as! String
                    let myGroup = Group(title: title, description: description, groupId: group.key, members: membersArray, membersCount: membersArray.count)
                    groupsArray.append(myGroup)
                }
            }
            handler(groupsArray)
        }
    }
    
}
