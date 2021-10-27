//
//  agendaCourseCell.swift
//  Yobli
//
//  Created by Brounie on 14/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class agendaCourseCell: UITableViewCell {
    
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
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
        }
    }
    
    func updateUI(){
        
        if let mainObject = objects{
            
            if let imageInformation = mainObject["logo"] as? PFFileObject{
                            
                imageInformation.getDataInBackground{
                                
                (imageData: Data?, error: Error?) in
                    if let error = error{
                            print(error.localizedDescription)
                    }else if let imageData = imageData{
                                        
                        let image = UIImage(data: imageData)
                                        
                        self.mainLogo.image = image
                                        
                        self.mainLogo.roundCompleteImageColor()
                                        
                    }
                                
                }
                            
            }else{
                            
                self.mainLogo.image = nil
                            
            }
            
            
            if let newName = mainObject["name"] as? String{
                self.serviceName.text = newName
            }else{
                self.serviceName.text = nil
            }
            
            if let newDate = mainObject["date"] as? Date{
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.locale = Locale(identifier: "es_ES")
                
                dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
                let labelDate = dateFormatter.string(from: newDate)
                
                self.serviceDate.text = labelDate
                
            }else{
                
                self.serviceDate.text = nil
                
            }
            
        }else{
            serviceName.text = nil
            serviceDate.text = nil
        }
    }
    
}
