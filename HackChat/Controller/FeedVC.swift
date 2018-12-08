//
//  FeedVC.swift
//  HackChat
//
//  Created by Milan Bojic on 11/27/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class FeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var messageArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DataService.instance.REF_FEED.observe(.value) { (snapshot) in
            DataService.instance.getFeedMessages { (returnedMessageArray) in
                self.messageArray = returnedMessageArray.reversed()
                self.tableView.reloadData()
            }
        }
    }
    
    func showImage(fromImageUrl urlString: String) {
        
    }

}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as? FeedCell else {return UITableViewCell()}
        let message = messageArray[indexPath.row]
        DataService.instance.getUsernameAndPhoto(forUID: message.senderId) { (returnedUsername, returnedProfilePhoto) in
            // check cache for image first
            if let cachedImage = imageCache.object(forKey: returnedProfilePhoto as AnyObject) as? UIImage {
                cell.configureCell(profileImage: cachedImage, email: returnedUsername, messageContent: message.content)
            }
            // otherwise download images
            let url = URL(string: returnedProfilePhoto)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: returnedProfilePhoto as AnyObject)
                            cell.configureCell(profileImage: downloadedImage, email: returnedUsername, messageContent: message.content)
                        }
                    }
                }
                }.resume()
        }
        return cell
    }
}

