//
//  exploreRegistrationSuccess.swift
//  Yobli
//
//  Created by Brounie on 09/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class exploreRegistrationSuccess: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var activityDate: UILabel!
    
    @IBOutlet weak var activityDetails: UITableView!
    
    //MARK: VARs/LETs
    
    var reservation = PFObject(className: "Reservation")
    
    var typeOfActivity = ""
    var pointerKey = ""
    
    var yoberEmail = ""
    var contact = [String:String]()
    var baseId : String?
    var isAlreadyAContact = false
    
    let userChatController = ChatMainController()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        
        activityDetails.delegate = self
        activityDetails.dataSource = self
        
        yoberPhoto.layer.cornerRadius = yoberPhoto.frame.size.width / 2
        yoberPhoto.layer.masksToBounds = true
        yoberPhoto.layer.borderColor = UIColor.init(red: 0, green: 215, blue: 255, alpha: 1).cgColor
        yoberPhoto.layer.borderWidth = 3
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func getInContact(_ sender: Any) {
        
        if(baseId == nil){
            
            self.createNewConversation(result: contact)
            
            
        }else{
            
            self.goToExistingConversation(result: contact)
            
        }
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        if let newDate = reservation["date"] as? Date{
                
            let dateFormatter = DateFormatter()
                
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
                
                
            let labelDate = dateFormatter.string(from: newDate)
                
            self.activityDate.text = labelDate
                
        }
            
        if let keyReserv = reservation["yoberId"] as? String{
            self.getUser(keyFromReservation: keyReserv)
        }else{
            print("This should not happen, there is always a userId when a new course is created")
        }
        
    }
    
    func getUser(keyFromReservation: String){
        
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:keyFromReservation)
        
        queryYober.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = object {
                // The find succeeded.
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
            
                if let newName = object["username"] as? String{
                    self.yoberName.text = newName
                }else{
                    self.yoberName.text = nil
                }
                
                if let newEmail = object["contactEmail"] as? String{
                    self.yoberEmail = newEmail
                    
                    self.contactUser(yoberEmail: self.yoberEmail)
                    self.getIfContact(yoberEmail: self.yoberEmail)
                }
                
                self.yoberGrade.image = UIImage(named: "starsBlue")
                
            }
            
        }
        
    }
    
    //MARK: FUNCTION CONTACTS
    
    func contactUser(yoberEmail: String){
        
        let correctedEmail = userChatController.safeNameUser(email: yoberEmail)
        userChatController.searchUser(name: correctedEmail)
        
        userChatController.completion = { [weak self] result in
                
            self?.contact = result
                
        }
        
    }
    
    func getIfContact(yoberEmail: String){
        
        guard let myUserEmail = PFUser.current()!.email else {
            return
        }
        
        let correctedEmail = userChatController.safeNameUser(email: yoberEmail)
        let userEmail = userChatController.safeNameUser(email: myUserEmail)
        
        userChatController.searchConversationId(yoberEmail: correctedEmail, userEmail: userEmail)
        
        userChatController.completionId = { [weak self] result in
            
            self?.baseId = result
        }
        
    }
    
    func createNewConversation(result: [String:String]){
        
        guard let name = result["name"], let email = result["email"], let emailUser = PFUser.current()!.email, let emailName = PFUser.current()!.username else{
            return
        }
        
        let viewController = messagePrivate(otherUserEmail: email, otherUserName: name, userEmail: emailUser, userName: emailName, id: baseId)
        
        viewController.title = name
        viewController.isNewConversation = true
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func goToExistingConversation(result: [String:String]){
        
        guard let name = result["name"], let email = result["email"], let emailUser = PFUser.current()!.email, let emailName = PFUser.current()!.username else{
            return
        }
        
        let viewController = messagePrivate(otherUserEmail: email, otherUserName: name, userEmail: emailUser, userName: emailName, id: baseId)
        
        viewController.title = name
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

//MARK: TABLIEVIEW EXTENSION

extension exploreRegistrationSuccess: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let typeOfActivity = reservation["type"] as? String{
            
            if(typeOfActivity == "Course"){
                
                return 4
                
            }else if (typeOfActivity == "Service"){
                
                return 4
                
            }else if(typeOfActivity == "Voluntary"){
                
                return 3
                
            }
            
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = activityDetails.dequeueReusableCell(withIdentifier: "exploreInscriptionCell3", for: indexPath) as! exploreInscriptionCell
        
        if(typeOfActivity == "Course" || typeOfActivity == "Service"){
            
            switch indexPath.row{
                
            case 1:
                
                if let newCost = reservation["price"] as? String{
                    cell.information.text = newCost
                    cell.icon.image = UIImage(named: "priceIcon")
                }else{
                    cell.information.text = nil
                }
                
            case 2:
                
                if let newTime = reservation["duration"] as? String{
                    cell.information.text = newTime
                    cell.icon.image = UIImage(named: "timeIcon")
                }else{
                    cell.information.text = nil
                }
                
            case 3:
                
                if let newLocation = reservation["location"] as? String{
                    cell.information.text = newLocation
                    cell.icon.image = UIImage(named: "zoneIcon")
                }else{
                    cell.information.text = nil
                }
                
            default:
                
                if let newName = reservation["name"] as? String{
                    cell.information.text = newName
                    cell.icon.image = UIImage(named: "activityIcon")
                }else{
                    cell.information.text = nil
                }
                
                    
            }
            
            
        }else if(typeOfActivity == "Voluntary"){
            
            switch indexPath.row{
                    
            case 1:
                    
                if let newTime = reservation["duration"] as? String{
                    cell.information.text = newTime
                    cell.icon.image = UIImage(named: "timeIcon")
                }else{
                    cell.information.text = nil
                }
                    
            case 2:
                    
                if let newLocation = reservation["location"] as? String{
                    cell.information.text = newLocation
                    cell.icon.image = UIImage(named: "zoneIcon")
                }else{
                    cell.information.text = nil
                }
                    
            default:
                    
                if let newName = reservation["name"] as? String{
                    cell.information.text = newName
                    cell.icon.image = UIImage(named: "activityIcon")
                }else{
                    cell.information.text = nil
                }
                    
            }
            
        }
        
        return cell
    }
    
    
}
