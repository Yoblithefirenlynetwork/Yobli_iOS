//
//  galleryCell.swift
//  Yobli
//
//  Created by Brounie on 01/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

protocol deleteGalleryCell: class {
    func deleteGCell(iObject: PFObject)
}

class galleryCell: UICollectionViewCell {
    
    @IBOutlet weak var activityImage : UIImageView!
    @IBOutlet weak var deleteImage: UIButton!
     
    var imageObject = PFObject(className: "Gallery")
    var delegate : deleteGalleryCell?
    
    @IBAction func goToDelete(_ sender: UIButton) {
        
        delegate?.deleteGCell(iObject: imageObject)
        
    }
    
}
