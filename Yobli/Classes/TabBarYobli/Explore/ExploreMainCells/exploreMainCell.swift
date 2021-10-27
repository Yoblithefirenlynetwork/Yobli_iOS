//
//  exploreMainCell.swift
//  Yobli
//
//  Created by Humberto on 7/24/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class exploreMainCell: UICollectionViewCell{
    
    //VARIABLES
    
    
    @IBOutlet weak var imageButton: UIImageView!
    
    
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
                        //self.imageButton.roundCompleteImage()
                        
                    }
                    
                }
                
            }else{
                
                self.imageButton.image = nil
                
            }
//            if let newName = object["name"] as? String{
//                self.exploreCategoryText.text = newName
//            }else{
//                self.exploreCategoryText.text = nil
//            }
            
        }else{
            imageButton.image = nil
            //exploreCategoryText.text = nil
        }
    }
    
}
