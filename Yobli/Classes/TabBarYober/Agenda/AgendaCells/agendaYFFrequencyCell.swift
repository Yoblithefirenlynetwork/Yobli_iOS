//
//  agendaYFFrequencyCell.swift
//  Yobli
//
//  Created by Brounie on 19/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit

protocol frequencySelectedDelegate:class {
    func frequencySelectedYN(stringFrequency: String, selected: Bool)
}

class agendaYFFrequencyCell: UITableViewCell {
    
    @IBOutlet weak var frequencyAgenda: UILabel!
    @IBOutlet weak var selectedFrequency: UIButton!
    
    var frequencyString = ""
    var mySelected = false
    weak var delegate : frequencySelectedDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func frequencySelected(_ sender: Any) {
        
        delegate?.frequencySelectedYN(stringFrequency: frequencyString, selected: mySelected)
        
    }
    
}
