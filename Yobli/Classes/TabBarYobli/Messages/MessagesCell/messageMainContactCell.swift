//
//  messageMainContactCell.swift
//  Yobli
//
//  Created by Brounie on 04/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class messageMainContactCell: UITableViewCell {
    
    @IBOutlet weak var contactPhoto: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var lastContactMessage: UILabel!

    public func configure(model: Conversation){
        
        self.lastContactMessage.text = model.latestMessage.text
        
        if( model.latestMessage.isRead == false ){
            
            self.contactName.font = UIFont(name: "Avenir-Heavy", size: 18)
            
            self.lastContactMessage.font = UIFont(name: "Avenir-Heavy", size: 12)
            
        }else{
            
            self.contactName.font = UIFont(name: "Avenir", size: 18)
            
            self.lastContactMessage.font = UIFont(name: "Avenir", size: 12)
            
        }
            
        
        let activityQuery = PFQuery(className: "_User")
        activityQuery.whereKey("objectId", contains: model.otherUserId)
        activityQuery.findObjectsInBackground { (objects, error) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let imageInformation = object["userPhoto"] as? PFFileObject {
                        imageInformation.getDataInBackground { (imageData: Data?, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if let imageData = imageData {
                                let image = UIImage(data: imageData)
                                self.contactPhoto.image = image
                                self.contactPhoto.roundCompleteImageColor()
                            }
                        }
                    } else {
                        self.contactPhoto.image = nil
                    }
                }
            }
        }
        
//        let path = "images/\(model.otherUserId)_profile_picture.jpeg"
//        print("id: \(model.otherUserId)")
//        StFirebaseController.shared.downloadURL(path: path, completion: { [weak self] result in
//
//            switch result{
//            case.success(let url):
//
//                DispatchQueue.main.async {
//
//                    let data = try? Data(contentsOf: url)
//
//                    if let imageData = data {
//                        let image = UIImage(data: imageData)
//                        self?.contactPhoto.image = image
//
//                        self?.contactPhoto.roundCompleteImageColor()
//
//                    }
//
//                }
//
//            case.failure(let error):
//                print("Something went wrong: \(error)")
//            }
//
//        })
        
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:model.otherUserId)
        
        queryYober.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = object {
                
                if let newName = object["name"] as? String{
                    
                    self.contactName.text = newName
                    
                }
                
            }
            
        }
        
    }

}
