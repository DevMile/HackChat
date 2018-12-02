//
//  UserCell.swift
//  HackChat
//
//  Created by Milan Bojic on 12/1/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var checkmark: UIImageView!
    var showing = false
    
    func configureCell(profileImage image: UIImage, email: String, isSelected: Bool) {
        self.profileImage.image = image
        self.emailLbl.text = email
        if isSelected {
            self.checkmark.isHidden = false
        } else {
            self.checkmark.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            if showing == false {
                checkmark.isHidden = false
                showing = true
            } else {
                checkmark.isHidden = true
                showing = false
            }
        }
    }

}
