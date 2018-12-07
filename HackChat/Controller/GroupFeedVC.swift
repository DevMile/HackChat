//
//  GroupFeedVC.swift
//  HackChat
//
//  Created by Milan Bojic on 12/4/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var groupMembersLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textField: InsetTextField!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var sendBtnViewHeight: NSLayoutConstraint!
    
    var group: Group?
    var messageArray = [Message]()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tableViewTapped() {
        textField.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLbl.text = group?.title
        DataService.instance.getEmailsFor(group: group!) { (returnedEmails) in
            self.groupMembersLbl.text = returnedEmails.joined(separator: ", ")
        }
        
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.groupMessagesFor(desiredGroup: self.group!) { (returnedGroupMessages) in
                self.messageArray = returnedGroupMessages
                self.tableView.reloadData()
                if self.messageArray.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: .none, animated: true)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
   
    @IBAction func sendBtnPressed(_ sender: Any) {
        if textField.text != "" && textField.text != "send a message..." {
            textField.isEnabled = false
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: textField.text!, userID: (Auth.auth().currentUser?.uid)!, withGroupKey: group?.groupId) { (success) in
                if success {
                    self.textField.text = ""
                    self.textField.isEnabled = true
                    self.sendBtn.isEnabled = true
                } else {
                    print("Error while uploading group message.")
                }
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissVC()
    }
    
    // animate sendBtnView
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeightSize = keyboardSize.height
            self.sendBtnViewHeight.constant = keyboardHeightSize + 60 // height of sendBtnView
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.sendBtnViewHeight.constant = 60
            self.view.layoutIfNeeded()
        }
    }
    
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell", for: indexPath) as? GroupFeedCell else {return UITableViewCell()}
        let image = UIImage(named: "defaultProfileImage")
        let groupMessage = messageArray[indexPath.row]
        DataService.instance.getUsername(forUID: groupMessage.senderId) { (returnedUsername) in
            cell.configureCell(profileImage: image!, emailLbl: returnedUsername, messageContentLbl: groupMessage.content)
        }
        return cell
    }
}
