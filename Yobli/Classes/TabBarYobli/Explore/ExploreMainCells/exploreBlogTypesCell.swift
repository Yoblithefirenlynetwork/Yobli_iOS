//
//  exploreBlogTypesCell.swift
//  Yobli
//
//  Created by Brounie on 07/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreBlogTypesCell: UICollectionViewCell {
    
    @IBOutlet weak var blogType: UILabel!
    @IBOutlet weak var blogImage: UIImageView!
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    
    func updateUI(){
        
        if let object = objects{
            
            if let newName = object["name"] as? String{
                self.blogType.text = newName
            }else{
                self.blogType.text = nil
            }
            
            blogImage.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
            blogImage.roundCustomImage(divider: 8)
            
        }else{
            blogImage.image = nil
            blogType.text = nil
        }
        
    }
    
}
