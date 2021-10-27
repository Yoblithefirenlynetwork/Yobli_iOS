//
//  exploreBlogListCell.swift
//  Yobli
//
//  Created by Brounie on 07/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreBlogListCell: UICollectionViewCell {
    
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var exploreCourseName: UILabel!
    
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
                        
                        self.imageButton.roundCustomImage(divider: 16)
                        
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
            
            
        }else{
            exploreCourseName.text = nil
            imageButton.image = nil
        }
        
    }
}
