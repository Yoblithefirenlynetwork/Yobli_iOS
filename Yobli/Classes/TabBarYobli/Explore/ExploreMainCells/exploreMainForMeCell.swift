//
//  exploreMainForMeCell.swift
//  Yobli
//
//  Created by Humberto on 7/28/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreMainForMeCell: UICollectionViewCell {
    
    //VARIABLES
    
    @IBOutlet weak var exploreSectionsText: UILabel!
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }

    
    func updateUI(){
        
        if let object = objects{
            
//            if let imageInformation = object["logo"] as? PFFileObject{
//
//                imageInformation.getDataInBackground{
//                    (imageData: Data?, error: Error?) in
//                    if (imageData != nil){
//
//                        let image = UIImage(data: imageData!)
//
//                        self.imageButton.image = image
//                        self.imageButton.roundCustomImage(divider: 16)
//
//                    }
//
//                }
//
//            }else{
//
//                self.imageButton.image = nil
//
//            }
            
            if let newName = object["name"] as? String{
                self.exploreSectionsText.text = newName
            }else{
                self.exploreSectionsText.text = nil
            }
            
        }else{
            //imageButton.image = nil
            exploreSectionsText.text = nil
        }
 
    }
 
}
