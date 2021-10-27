//
//  ExploreInscriptionCell.swift
//  Yobli
//
//  Created by Brounie on 31/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class exploreInscriptionCell: UITableViewCell {
    
    @IBOutlet weak var icon : UIImageView!
    @IBOutlet weak var information : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
