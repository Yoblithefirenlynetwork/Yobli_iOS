//
//  ShadowView.swift
//  Yobli
//
//  Created by Rodrigo Rivera on 29/03/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor//UIColor(red: 0, green: 0, blue: 0, alpha: 0.35).cgColor
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 2.0
        
        self.layer.cornerRadius = 15
    }

}
