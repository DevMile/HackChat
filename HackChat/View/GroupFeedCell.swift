//
//  GroupFeedCell.swift
//  HackChat
//
//  Created by Milan Bojic on 12/4/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var messageContentLbl: UILabel!
    
    func configureCell(profileImage: UIImage, emailLbl: String, messageContentLbl: String) {
        self.profileImage.maskCircle(anyImage: profileImage)
        self.emailLbl.text = emailLbl
        self.messageContentLbl.text = messageContentLbl
    }
}
