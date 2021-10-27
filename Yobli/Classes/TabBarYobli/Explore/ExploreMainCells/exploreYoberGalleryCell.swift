//
//  exploreYoberGalleryCell.swift
//  Yobli
//
//  Created by Brounie on 17/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

protocol GalleryRowDelegate:class {
    func cellGallery(position: Int)
}

class exploreYoberGalleryCell: UICollectionViewCell {

    @IBOutlet weak var imageButton: UIImageView!
    
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
            
            if let imageInformation = object["photoGallery"] as? PFFileObject{
            
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
                
                self.imageButton.roundCustomImage(divider: 16)
                
            }
            
            
        }else{
            imageButton.image = nil
        }
    }


}
