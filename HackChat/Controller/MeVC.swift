//
//  MeVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/29/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailLbl.text = Auth.auth().currentUser?.email
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are your sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (buttonPressed) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (buttontapped) in
            self.dismiss(animated: true, completion: nil)
        }
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(cancelAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
    


}
