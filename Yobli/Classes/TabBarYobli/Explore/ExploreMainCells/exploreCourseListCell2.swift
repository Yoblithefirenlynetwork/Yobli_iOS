//
//  exploreCourseListCell2.swift
//  Yobli
//
//  Created by Humberto on 8/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreCourseListCell2: UICollectionViewCell {
    
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var exploreCourseTime: UILabel!
    @IBOutlet weak var exploreCourseName: UILabel!
    @IBOutlet weak var exploreCourseCost: UILabel!
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    
    func updateUI(){
        
        if let object = objects{
            
            if let imageInformation = object["logo"] as? PFFileObject{
            
                imageInformation.getDataInBackground{
                    
                    (imageData: Data?, error: Error?) in
                    if let error = error{
                        print(error.localizedDescription)
                    }else if let imageData = imageData{
                        
                        let image = UIImage(data: imageData)
                        
                        self.imageButton.image = image
                        
                        self.imageButton.layer.cornerRadius = self.imageButton.frame.size.width / 16
                        self.imageButton.layer.masksToBounds = true
                        
                    }
                    
                }
            
            }else{
                
                self.imageButton.image = nil
                
                self.imageButton.layer.cornerRadius = self.imageButton.frame.size.width / 16
                self.imageButton.layer.masksToBounds = true
                
            }
            
            
            
            if let newName = object["name"] as? String{
                self.exploreCourseName.text = newName
            }else{
                self.exploreCourseName.text = nil
            }
            
            if let newCost = object["price"] as? String{
                self.exploreCourseCost.text = newCost
            }else{
                self.exploreCourseCost.text = nil
            }
            
            if let newDate = object["date"] as? Date{
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "YYYY/MM/dd"
                
                let labelDate = dateFormatter.string(from: newDate)
                
                self.exploreCourseTime.text = labelDate
                
            }else{
                
                self.exploreCourseTime.text = nil
                
            }
            
            
        }else{
            exploreCourseTime.text = nil
            exploreCourseCost.text = nil
            exploreCourseName.text = nil
            imageButton.image = nil
        }
        
    }
    
}
