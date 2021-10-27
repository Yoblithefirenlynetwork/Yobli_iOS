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
import MBProgressHUD

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
    
    var yoberId = ""
    var yoberNamefrId = ""
    var contact = [String:String]()
    var conversationUserSideId : String?
    var conversationYoberSideId: String?
    var cardSelected = ""
    
    let userChatController = ChatMainController()
    
    var AppearOnce = true
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Fill view
        self.showHUD(progressLabel: "Cargando...")
        
        self.updateView()
        
        activityDetails.delegate = self
        activityDetails.dataSource = self
        
        yoberPhoto.roundCompleteImageColor()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
            
        }
        
        if(AppearOnce != true){
        
            self.showHUD(progressLabel: "Actualizando...")
            self.updateView()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func getInContact(_ sender: Any) {
        
        if(conversationUserSideId == nil && conversationYoberSideId == nil){
            
            self.createNewConversation()
                
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
            
        if let yober = reservation["yober"] as? PFObject{
            self.getUser(yober: yober)
        }else{
            print("This should not happen, there is always a yoberId when a new reservation is created")
        }
        
    }
    
    func getUser(yober: PFObject){
        
        if let imageInformation = yober["userPhoto"] as? PFFileObject{
            
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
            
        if let newName = yober["name"] as? String {
            self.yoberNamefrId = newName
            self.yoberName.text = newName
        }else{
            self.yoberName.text = nil
        }
                
        if let newId = yober.objectId{
            self.yoberId = newId
            self.yoberGrade.gradeResults(id: self.yoberId)
            self.contactUser()
            self.getIfContact()
        }
        
    }
    
    //MARK: FUNCTION CONTACTS
    
    func contactUser(){
        
        userChatController.searchUser(id: yoberId)
        
        userChatController.completion = { [weak self] result in
                
            self?.contact = result
                
        }
        
    }
    
    func getIfContact(){
        
        guard let myUserId = PFUser.current()!.objectId else {
            return
        }
        
        userChatController.searchConversationIdInSender(receiverId: yoberId, senderId: myUserId)
        userChatController.searchConversationIdInReceiver(receiverId: yoberId, senderId: myUserId)
        
        userChatController.completionId = { [weak self] result in
            
            self?.conversationUserSideId = result
            
        }
        
        userChatController.completionId2 = { [weak self] result2 in
         
            self?.conversationYoberSideId = result2
            
        }
        
        AppearOnce = false
        self.dismissHUD(isAnimated: true)
        
    }
    
    func createNewConversation(){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String  else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: true)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func goToExistingConversation(result: [String:String]){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: false)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

//MARK: TABLIEVIEW EXTENSION

extension exploreRegistrationSuccess: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let typeOfActivity = reservation["type"] as? String{
            
            if(typeOfActivity == "Course"){
                
                return 5
                
            }else if (typeOfActivity == "Service"){
                
                return 5
                
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
                
            case 4:
                
                cell.information.text = cardSelected
                cell.icon.image = UIImage(named: "cardIcon")
                
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

extension exploreRegistrationSuccess{
    
    func showHUD(progressLabel:String){
        DispatchQueue.main.async{
            let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.backgroundView.color = UIColor.gray
            loader.backgroundView.alpha = 0.5
            loader.label.text = progressLabel
        }
    }

    func dismissHUD(isAnimated:Bool) {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: isAnimated)
        }
    }
    
}
