//
//  agendaYATimesCell.swift
//  Yobli
//
//  Created by Brounie on 16/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit

protocol timeSelectedDelegate:class {
    func timeSelectedYN(stringTime: String, selected: Bool)
}

class agendaYATimesCell: UITableViewCell {
    
    @IBOutlet weak var timeAgenda: UILabel!
    @IBOutlet weak var selectTime: UIButton!
    
    var timeString = ""
    var mySelected = false
    weak var delegate : timeSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func timeSelected(_ sender: Any) {
        
        delegate?.timeSelectedYN(stringTime: timeString, selected: mySelected)
        
    }
    

}
