//
//  exploreVoluntaryListCell.swift
//  Yobli
//
//  Created by Humberto on 8/7/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreVoluntaryListCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var exploreVoluntaryTitle: UILabel!
    @IBOutlet weak var exploreVoluntaryState: UILabel!
    @IBOutlet weak var exploreVoluntaryDate: UILabel!
    
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
                self.exploreVoluntaryTitle.text = newName
            }else{
                self.exploreVoluntaryTitle.text = nil
            }
            
            if let newCity = object["state"] as? String{
                self.exploreVoluntaryState.text = newCity
            }else{
                self.exploreVoluntaryState.text = nil
            }
            
            if let newDate = object["date"] as? Date{
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "YYYY/MM/dd"
                
                let labelDate = dateFormatter.string(from: newDate)
                
                self.exploreVoluntaryDate.text = labelDate
                
            }else{
                
                self.exploreVoluntaryDate.text = nil
                
            }
            
        }else{
            imageButton.image = nil
            exploreVoluntaryTitle.text = nil
            exploreVoluntaryState.text = nil
            exploreVoluntaryDate.text = nil
        }
        
    }
    
}
