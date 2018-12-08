//
//  FeedCell.swift
//  HackChat
//
//  Created by Milan Bojic on 11/30/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(profileImage: UIImage, email: String, messageContent: String) {
        self.profileImage.maskCircle(anyImage: profileImage)
        self.emailLbl.text = email
        self.contentLbl.text = messageContent
    }
    
    
    
}
