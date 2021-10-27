//
//  exploreCourseSectHeadUp.swift
//  Yobli
//
//  Created by Humberto on 8/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit

class exploreHeaderCollection: UICollectionReusableView{
    
    @IBOutlet weak var headerTitle: UILabel!
    
    
    var typeTitle: String?{
        didSet {
            if let titleType = typeTitle{
                headerTitle.text = titleType
            }
            else{
                headerTitle.text = nil
            }
        }
    }
    
}
