//
//  CreateGroupsVC.swift
//  HackChat
//
//  Created by Milan Bojic on 12/1/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupsVC: UIViewController {
    
    @IBOutlet weak var addTitleTxtField: InsetTextField!
    @IBOutlet weak var descriptionTxtField: InsetTextField!
    @IBOutlet weak var addMembersTxtField: InsetTextField!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    var emailArray = [String]()
    var chosenGroupMembers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        addMembersTxtField.delegate = self
        addMembersTxtField.addTarget(self, action: #selector(searchMemberEmail), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        doneBtn.isHidden = true
    }
    
    @objc func searchMemberEmail() {
        if addMembersTxtField.text == "" {
            emailArray = []
            tableView.reloadData()
        } else {
            DataService.instance.getEmails(forSearchQuery: addMembersTxtField.text!) { (returnedEmailArray) in
                self.emailArray = returnedEmailArray
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if addTitleTxtField.text != "" && descriptionTxtField.text != "" {
            DataService.instance.getIds(forUsernames: chosenGroupMembers) { (returnedUserIds) in
                var idArray = returnedUserIds
                idArray.append((Auth.auth().currentUser?.uid)!)
                DataService.instance.createGroup(withTitle: self.addTitleTxtField.text!, andDescription: self.descriptionTxtField.text!, forUserIds: idArray, completion: { (success) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let errorPopup = UIAlertController(title: "Error", message: "There has been an error while creating your group. Please try again.", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { (buttontapped) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        errorPopup.addAction(cancelAction)
                        self.present(errorPopup, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CreateGroupsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as? UserCell else {return UITableViewCell()}
        let image = UIImage(named: "defaultProfileImage")
        if chosenGroupMembers.contains(emailArray[indexPath.row]) {
            cell.configureCell(profileImage: image!, email: emailArray[indexPath.row], isSelected: true)
        } else {
            cell.configureCell(profileImage: image!, email: emailArray[indexPath.row], isSelected: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UserCell else {return}
        if !chosenGroupMembers.contains(cell.emailLbl.text!) {
            chosenGroupMembers.append(cell.emailLbl.text!)
            membersLabel.text = chosenGroupMembers.joined(separator: ", ")
            doneBtn.isHidden = false
        } else {
            chosenGroupMembers = chosenGroupMembers.filter({$0 != cell.emailLbl.text!})
            if chosenGroupMembers.count >= 1 {
                membersLabel.text = chosenGroupMembers.joined(separator: ", ")
            } else {
                membersLabel.text = "add people to your group"
                doneBtn.isHidden = true
            }
        }
    }
    
}

extension CreateGroupsVC: UITextFieldDelegate {}
