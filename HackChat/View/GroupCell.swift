//
//  GroupCell.swift
//  HackChat
//
//  Created by Milan Bojic on 12/3/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var groupDescription: UILabel!
    @IBOutlet weak var membersCount: UILabel!
    
    func configureCell(title: String, description: String, membersCount: Int) {
        self.groupTitle.text = title
        self.groupDescription.text = description
        self.membersCount.text = "\(membersCount) members"
    }
}
