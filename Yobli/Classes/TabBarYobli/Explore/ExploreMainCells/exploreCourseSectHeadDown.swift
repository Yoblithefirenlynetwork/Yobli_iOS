//
//  exploreCourseSectHeadDown.swift
//  Yobli
//
//  Created by Humberto on 8/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

protocol exploreToCourseDelegate {
    func passData(typeToWatch: PFObject)
}

class exploreCourseSectHeadDown: UICollectionReusableView{
    
    var delegate: exploreToCourseDelegate?
    
    @IBOutlet weak var watchMore: UIButton!
    
    var typeToGo = PFObject(className: "Type")
    
    
    @IBAction func goToView(_ sender: UIButton) {
        
        delegate?.passData(typeToWatch: typeToGo)
        
    }
    
    
    
}
