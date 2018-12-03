//
//  GroupsVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/27/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

class GroupsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var groupsArray = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.getAllGroups { (returnedGroupsArray) in
            self.groupsArray = returnedGroupsArray
            self.tableView.reloadData()
        }
    }


}

extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath) as? GroupCell else {return UITableViewCell()}
        let group = groupsArray[indexPath.row]
        cell.configureCell(title: group.title, description: group.description, membersCount: group.membersCount)
        return cell
    }
}

