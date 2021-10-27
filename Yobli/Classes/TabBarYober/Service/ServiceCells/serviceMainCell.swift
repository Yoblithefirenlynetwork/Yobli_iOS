//
//  serviceMainCell.swift
//  Yobli
//
//  Created by Brounie on 13/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class serviceMainCell: UITableViewCell {
    
    @IBOutlet weak var mainLogo: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
