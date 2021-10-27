//
//  exploreCategoryMainCell.swift
//  Yobli
//
//  Created by Humberto on 7/31/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreCategoryMainCell: UICollectionViewCell {
    
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var exploreYoberNameText: UILabel!
    @IBOutlet weak var imageYoberGrade: UIImageView!
    
    var grade: Double = 0.0
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
        
        if let object = objects {
            
            let gradeYoderQuery = PFQuery(className: "Grade")
            gradeYoderQuery.whereKey("yober", contains: object.objectId)
            gradeYoderQuery.getFirstObjectInBackground { (yober, error) in
                if let error = error {
                    print("error: \(error)")
                }else{
                    self.grade = yober?["grade"] as? Double ?? 0.0
                    
                    self.imageYoberGrade.image = supportView.getGradeWhiteImage(grade: self.grade)
                }
            }
                
            if let imageInformation = object["userPhoto"] as? PFFileObject{
                
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
                
            }
            
            if let newName = object["name"] as? String {
                self.exploreYoberNameText.text = newName
            }else{
                self.exploreYoberNameText.text = nil
            }
            
        }else{
            imageYoberGrade.image = nil
            imageButton.image = nil
            exploreYoberNameText.text = nil
        }
        
    }
}
