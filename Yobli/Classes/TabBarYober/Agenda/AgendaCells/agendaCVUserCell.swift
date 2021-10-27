//
//  agendaCVUserCell.swift
//  Yobli
//
//  Created by Brounie on 27/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit

protocol ContactClientUser:class{
    func getIfContact(position: Int)
}

class agendaCVUserCell: UITableViewCell {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userContact: UIButton!
    
    var position = 0
    
    weak var delegate: ContactClientUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func contactUser(_ sender: UIButton) {
        
        delegate?.getIfContact(position: position)
        
    }
    
}
