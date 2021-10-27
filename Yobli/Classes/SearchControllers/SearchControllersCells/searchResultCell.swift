//
//  searchResultCell.swift
//  Yobli
//
//  Created by Brounie on 02/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class searchResultCell: UITableViewCell {
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultName: UILabel!
    
    var object: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    
    func updateUI(){
        
        if let object = object{
            
            if let imageInformation = object["logo"] as? PFFileObject{
            
                imageInformation.getDataInBackground{
                    
                    (imageData: Data?, error: Error?) in
                    if let error = error{
                        print(error.localizedDescription)
                    }else if let imageData = imageData{
                        
                        let image = UIImage(data: imageData)
                        
                        self.resultImage.image = image
                        
                        self.resultImage.roundCompleteImage()
                        
                    }
                    
                }
            
            }else if let imageInformation = object["userPhoto"] as? PFFileObject{
                
                imageInformation.getDataInBackground{
                    
                    (imageData: Data?, error: Error?) in
                    if let error = error{
                        print(error.localizedDescription)
                    }else if let imageData = imageData{
                        
                        let image = UIImage(data: imageData)
                        
                        self.resultImage.image = image
                        
                        self.resultImage.roundCompleteImage()
                        
                    }
                    
                }
            
            }else{
                
                self.resultImage.image = nil
                
                self.resultImage.roundCompleteImage()
                
            }
            
            
            if let newName = object["name"] as? String{
                self.resultName.text = newName
            }else if let newName = object["name"] as? String{
                self.resultName.text = newName
            }else{
                self.resultName.text = nil
            }
            
            
        }else{
            resultImage.image = nil
            resultName.text = nil
        }
        
    }
}
