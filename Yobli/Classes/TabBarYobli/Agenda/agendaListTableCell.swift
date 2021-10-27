//
//  agendaListTableCell.swift
//  Yobli
//
//  Created by Brounie on 02/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class agendaListTableCell: UITableViewCell {
    
    @IBOutlet weak var colorOfActivity: UIView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
        
        if let object = objects{
            
            if let newDate = object["date"] as? Date{
                
                let dateFormatter = DateFormatter()
                
                
                dateFormatter.locale = Locale(identifier: "es_MX")
                dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
                dateFormatter.amSymbol = "AM"
                dateFormatter.pmSymbol = "PM"
                
                
                let labelDate = dateFormatter.string(from: newDate)
                
                self.activityDate.text = labelDate
                
            }else{
                
                self.activityDate.text = nil
                
            }
            
            if let newName  = object["name"] as? String{
                self.activityName.text = newName
            }else{
                self.activityName.text = nil
            }
            
            if let newType = object["type"] as? String{
                
                if(newType == "Voluntary"){
                    
                    colorOfActivity.backgroundColor = UIColor.init(red: 255/255, green: 223/255, blue: 0, alpha: 1)
                    colorOfActivity.roundCompleteView()
                    
                }else if(newType == "Course"){
                    
                    colorOfActivity.backgroundColor = UIColor.init(red: 255/255, green: 0, blue: 149/255, alpha: 1)
                    colorOfActivity.roundCompleteView()
                    
                }else{
                    
                    colorOfActivity.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
                    colorOfActivity.roundCompleteView()
                    
                }
                
            }

        }else{
            
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
