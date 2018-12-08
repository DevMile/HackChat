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
let STORAGE = Storage.storage().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    private var _REF_STORAGE = STORAGE
    
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
    
    var REF_STORAGE: StorageReference {
        return _REF_STORAGE
    }
    
    func createDBUser(userId: String, userData: Dictionary<String,Any>) {
        REF_USERS.child(userId).updateChildValues(userData)
    }
    
    func uploadPost(withMessage message: String, userID uid: String, withGroupKey groupKey: String?, sendComplete: @escaping (_ status: Bool) -> ()) {
        if groupKey != nil {
            // send post to groups
            REF_GROUPS.child(groupKey!).child("messages").childByAutoId().updateChildValues(["content": message, "senderId": uid])
            sendComplete(true)
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
    
    func groupMessagesFor(desiredGroup: Group, handler: @escaping (_ messagesArray: [Message]) -> ()) {
        var messagesArray = [Message]()
        REF_GROUPS.child(desiredGroup.groupId).child("messages").observeSingleEvent(of: .value) { (groupMessages) in
            guard let groupMessages = groupMessages.children.allObjects as? [DataSnapshot] else {return}
            for message in groupMessages {
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                let message = Message(content: content, senderId: senderId)
                messagesArray.append(message)
            }
            handler(messagesArray)
        }
    }
    
    func getUsernameAndPhoto(forUID uid: String, handler: @escaping (_ username: String, _ profilePhoto: String) -> ()) {
        let query = REF_USERS.child(uid)
        query.observeSingleEvent(of: .value) { (userSnapshot) in
            let email = userSnapshot.childSnapshot(forPath: "email").value as! String
            let profilePhoto = userSnapshot.childSnapshot(forPath: "profile_pic").value as! String
            handler(email, profilePhoto)
        }
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
    
    func getEmailsFor(group: Group, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let users = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in users {
                if group.members.contains(user.key) {
                let email = user.childSnapshot(forPath: "email").value as! String
                emailArray.append(email)
                }
            }
            handler(emailArray)
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
    
    func uploadProfilePicture(forUID uid: String, imageUrl: String, completion: @escaping (_ success: Bool) -> ()) {
        REF_USERS.child(uid).child("profile_pic").setValue(imageUrl)
        completion(true)
    }
    
    func getUsers(handler: @escaping (_ usersArray: [User]) -> ()) {
        var usersArray = [User]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let users = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            for user in users {
                let email = user.childSnapshot(forPath: "email").value as! String
                let profile_pic = user.childSnapshot(forPath: "profile_pic").value as! String
                let userId = user.key
                let user = User(email: email, profile_pic: profile_pic, userId: userId)
                usersArray.append(user)
            }
            handler(usersArray)
        }
    }
    
    
    
}
