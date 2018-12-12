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
    var users = [User]()
    
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
            users = []
            tableView.reloadData()
        } else {
            DataService.instance.getEmailsAndUsers(forSearchQuery: addMembersTxtField.text!) { (returnedEmailArray, returnedUsersArray) in
                self.emailArray = returnedEmailArray
                self.users = returnedUsersArray
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
        // FIX UNEXPECTED CRASHES when typing too fast BECAUSE INDEX OUT OF RANGE !!!!
        if chosenGroupMembers.contains(emailArray[indexPath.row]) {
            // check cache for image first
            if let cachedImage = imageCache.object(forKey: users[indexPath.row].profile_pic as AnyObject) as? UIImage {
                cell.configureCell(profileImage: cachedImage, email: self.emailArray[indexPath.row], isSelected: true)
            }
            // otherwise download images
            let url = URL(string: users[indexPath.row].profile_pic)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: self.users[indexPath.row].profile_pic as AnyObject)
                            cell.configureCell(profileImage: downloadedImage, email: self.emailArray[indexPath.row], isSelected: true)
                        }
                    }
                }
                }.resume()
        } else {
            // check cache for image first
            if let cachedImage = imageCache.object(forKey: users[indexPath.row].profile_pic as AnyObject) as? UIImage {
                cell.configureCell(profileImage: cachedImage, email: self.emailArray[indexPath.row], isSelected: false)
            }
            // otherwise download images
            let url = URL(string: users[indexPath.row].profile_pic)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: self.users[indexPath.row].profile_pic as AnyObject)
                            cell.configureCell(profileImage: downloadedImage, email: self.emailArray[indexPath.row], isSelected: false)
                        }
                    }
                }
                }.resume()
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
