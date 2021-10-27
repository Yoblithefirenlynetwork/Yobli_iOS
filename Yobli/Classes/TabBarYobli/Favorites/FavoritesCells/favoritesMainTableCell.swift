//
//  favoritesMainTableCell.swift
//  Yobli
//
//  Created by Brounie on 27/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import UIKit
import Parse

class favoritesMainTableCell: UITableViewCell {
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    @IBOutlet weak var yoberName: UILabel!
    @IBOutlet weak var yoberDescription: UILabel!
    @IBOutlet weak var yoberHeart: UIImageView!
    
    var objects: PFObject!{
        didSet{
            self.updateUI()
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
    
    func updateUI(){
        
        if let object = objects{
            
            if let imageInformation = object["userPhoto"] as? PFFileObject{
            
                imageInformation.getDataInBackground{
                    
                    (imageData: Data?, error: Error?) in
                    if let error = error{
                        print(error.localizedDescription)
                    }else if let imageData = imageData{
                        
                        let image = UIImage(data: imageData)
                        
                        self.yoberPhoto.image = image
                    }
                    
                }
            
            }
            
            self.yoberPhoto.roundCompleteImageColor()
            
            if let newName = object["name"] as? String{
                self.yoberName.text = newName
            }else{
                self.yoberName.text = nil
            }
            
            if let newDescription = object["category"] as? String{
                self.yoberDescription.text = newDescription
            }else{
                self.yoberDescription.text = nil
            }
            
        }else{
            yoberName.text = nil
            yoberPhoto.image = nil
            yoberHeart.image = nil
            yoberDescription.text = nil
        }
    }
}
