//
//  exploreYoberCourseCell.swift
//  Yobli
//
//  Created by Brounie on 17/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

protocol CourseRowDelegate:class {
    func cellCourse(position: Int)
}

class exploreYoberCourseCell: UICollectionViewCell {

    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
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
                        
                        self.imageButton.layer.cornerRadius = self.imageButton.frame.size.width / 2
                        self.imageButton.layer.masksToBounds = true
                        
                    }
                    
                }
            
            }else{
                
                self.imageButton.image = nil
                
                self.imageButton.layer.cornerRadius = self.imageButton.frame.size.width / 16
                self.imageButton.layer.masksToBounds = true
                
            }
            
            if let newName = object["name"] as? String{
                self.titleText.text = newName
            }else{
                self.titleText.text = nil
            }
            
            
        }else{
            imageButton.image = nil
            titleText.text = nil
        }
    }
    
}
