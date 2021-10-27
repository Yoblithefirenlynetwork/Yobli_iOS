//
//  exploreMainYoberCell.swift
//  Yobli
//
//  Created by Humberto on 7/28/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreMainYoberCell: UICollectionViewCell {
    
    //VARIABLES
    
    
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var exploreYoberNameText: UILabel!
    @IBOutlet weak var imageYoberGrade: UIImageView!
    
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
        
        if let object = objects{
            
            guard let yober = object["yober"] as? PFObject, let grade = object["grade"] as? Double else{
                
                print("Something went wrong here")
                
                return
                
            }
            
            if let imageInformation = yober["userPhoto"] as? PFFileObject{
                
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
                
            }
            
            
            if let newName = yober["name"] as? String {
                self.exploreYoberNameText.text = newName
            }else{
                self.exploreYoberNameText.text = nil
            }
            
            self.imageYoberGrade.image = supportView.getGradeWhiteImage(grade: grade)
            
        }else{
            imageYoberGrade.image = nil
            imageButton.image = nil
            exploreYoberNameText.text = nil
        }
    }
    
}
