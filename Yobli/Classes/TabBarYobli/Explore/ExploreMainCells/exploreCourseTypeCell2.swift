//
//  exploreCourseTypeCell2.swift
//  Yobli
//
//  Created by Humberto on 8/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreCourseTypeCell2: UICollectionViewCell {
    
    @IBOutlet weak var courseType: UILabel!
    @IBOutlet weak var courseImage: UIImageView!
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    
    func updateUI(){
        
        if let object = objects{
            
            if let newName = object["name"] as? String{
                self.courseType.text = newName
            }else{
                self.courseType.text = nil
            }
            
            courseImage.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
            courseImage.roundCustomImage(divider: 8)
            
        }else{
            courseImage.image = nil
            courseType.text = nil
        }
        
    }
    
}
