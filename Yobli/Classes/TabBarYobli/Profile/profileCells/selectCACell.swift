//
//  selectCACell.swift
//  Yobli
//
//  Created by Brounie on 22/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit

protocol selectOptionCA: class {
    
    func selectedOption(type: String, position: Int)
    
}

class selectCACell: UITableViewCell {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var textContent: UILabel!
    
    var delegate : selectOptionCA?
    var typeOfContent = ""
    var numberInArray = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectThisCell(_ sender: Any) {
        
        delegate?.selectedOption(type: typeOfContent, position: numberInArray)
        
    }
    

}
