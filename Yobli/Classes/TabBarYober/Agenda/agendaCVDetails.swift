//
//  agendaCVDetails.swift
//  Yobli
//
//  Created by Brounie on 14/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class agendaCVDetails: UIViewController, ContactClientUser{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var activityPicture: UIImageView!
    
    @IBOutlet weak var activityName: UILabel!
    
    @IBOutlet weak var activitySmallDescription: UILabel!
    
    @IBOutlet weak var activityDate: UILabel!
    
    @IBOutlet weak var activityPlace: UILabel!
    
    @IBOutlet weak var activityPrice: UILabel!
    
    @IBOutlet var typeOfSubscriber: UILabel!
    
    @IBOutlet weak var subscriberTable: UITableView!
    
    // MARK: VARs/LETs
    var schedule = Date()
    var type = ""
    var activityId = ""
    var subscribers = [PFObject]()
    var isAgenda = false
    
    let userChatController = ChatMainController()
    var conversationSenderSideId : String?
    var conversationReceiverSideId: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        subscriberTable.delegate = self
        subscriberTable.dataSource = self
        
        activityPicture.roundCompleteImage()
        
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
         
            self.sendAlert()
        }
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        self.activityPicture.layer.borderColor = UIColor.black.cgColor
        self.activityPicture.layer.borderWidth = 0.5
        
        let activityQuery = PFQuery(className: type)
        activityQuery.whereKey("objectId", equalTo: activityId)
        
        activityQuery.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let object = object {
                
                if let imageInformation = object["logo"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            self.activityPicture.image = image
                        }
                        
                    }
                
                }else{
                    
                    self.activityPicture.image = nil
                    
                }
                
                if let newName = object["name"] as? String{
                    self.activityName.text = newName
                }else{
                    self.activityName.text = nil
                }
                
                if let newSmallDescription = object["smallDescription"] as? String{
                    self.activitySmallDescription.text = newSmallDescription
                }else{
                    self.activitySmallDescription.text = nil
                }
                
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
                
                if let newLocation = object["location"] as? String{
                    self.activityPlace.text = newLocation
                }else{
                    self.activityPlace.text = nil
                }
                
                if let newPrice = object["price"] as? String{
                    self.activityPrice.text = newPrice
                }else{
                    self.activityPrice.text = nil
                }
                
                if(self.type == "Course"){
                    
                    self.typeOfSubscriber.text = "Cliente(s)"
                    
                }else{
                    
                    self.typeOfSubscriber.text = "Voluntario(s)"
                    
                }
                
                self.getAllReserves(activityId: self.activityId, type: self.type)
                
            }
            
        }
        
    }
    
    //MARK: GETALL RESERVES
    
    func getAllReserves(activityId: String, type: String){
        
        if(self.type == "Service"){
            
            let activityQuery = PFQuery(className: "Reservation")
            activityQuery.whereKey("type", equalTo: type)
            activityQuery.whereKey("activityId", equalTo: activityId)
            //activityQuery.whereKey("active", equalTo: false) Estaba en true
            activityQuery.includeKey("user")
            
            activityQuery.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    
                    for reservation in objects {
                        
                        if self.isAgenda == false {
                            if self.schedule == reservation["date"] as? Date {
                                if let client = reservation["user"] as? PFObject{
                                    self.subscribers.append(client)
                                }
                            }
                        }else{
                            if let client = reservation["user"] as? PFObject{
                                self.subscribers.append(client)
                            }
                        }
                    }
                    self.subscriberTable.reloadData()
                }
            }
        }else{
            
            let activityQuery = PFQuery(className: "Reservation")
            activityQuery.whereKey("type", equalTo: type)
            activityQuery.whereKey("activityId", equalTo: activityId)
            //activityQuery.whereKey("active", equalTo: false) Estaba en true
            activityQuery.includeKey("user")
            
            activityQuery.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects {
                    for reservation in objects {
                        if let client = reservation["user"] as? PFObject{
                            self.subscribers.append(client)
                        }
                    }
                    self.subscriberTable.reloadData()
                }
            }
        }
    }
}

//MARK: EXTENSION TABLEVIEW

extension agendaCVDetails: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        subscribers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = subscriberTable.dequeueReusableCell(withIdentifier: "agendaCVUserCell1") as! agendaCVUserCell
        
        if let imageInformation = subscribers[indexPath.row]["userPhoto"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    cell.userPhoto.image = image
                    
                    cell.userPhoto.roundCompleteImageColor()
                    
                }
                
            }
        
        }else{
            
            cell.userPhoto.image = nil
            
            cell.userPhoto.roundCompleteImageColor()
            
        }
        
        if let newName = subscribers[indexPath.row]["name"] as? String {
            cell.userName.text = newName
        }else{
            cell.userName.text = nil
        }
        
        cell.delegate = self
        cell.position = indexPath.row
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "agendaClienteDetails") as? agendaClienteDetails
        
        if let objectId = subscribers[indexPath.row].objectId{
            
            viewController?.subscriberId = objectId
            
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    //MARK: CONTACT FUNCTIONS
    
    func getIfContact(position: Int){
        
        guard let myUserId = PFUser.current()!.objectId, let receiverId = subscribers[position].objectId else {
            return
        }
        
        userChatController.searchConversationIdInSender(receiverId: receiverId, senderId: myUserId)
        userChatController.searchConversationIdInReceiver(receiverId: receiverId, senderId: myUserId)
        
        userChatController.completionId = { [weak self] result in
            
            self?.conversationSenderSideId = result
            
            self?.userChatController.completionId2 = { [weak self] result2 in
             
                self?.conversationReceiverSideId = result2
                
                if(self?.conversationSenderSideId == nil && self?.conversationReceiverSideId == nil){
                    
                    self?.goToNew(object: self!.subscribers[position] )
                        
                }else{
                        
                    self?.goToExisting(object: self!.subscribers[position] )
                        
                }
                
            }
            
        }
        
        
    }
    
    func goToNew(object: PFObject){
        
        print("Didnt found id")
        
        guard let idUser = PFUser.current()!.objectId, let userName = object["name"] as? String, let receiverId = object.objectId, let receiverName = object["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactUser(otherUserId: receiverId, otherUserName: receiverName, userId: idUser, userName: userName, senderSideId: conversationSenderSideId, receiverSideId: conversationReceiverSideId, isNew: true)
        
        //TAB POSITION
        
        let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
        
        tabbar.selectedIndex = 3
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            navigation.pushViewController(viewController, animated: true)
                
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
            appDelegate.window?.rootViewController = tabbar
            
        }
        
    }
    
    func goToExisting(object: PFObject){
        
        print("Found id")
        
        guard let idUser = PFUser.current()!.objectId, let userName = object["name"] as? String, let receiverId = object.objectId, let receiverName = object["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactUser(otherUserId: receiverId, otherUserName: receiverName, userId: idUser, userName: userName, senderSideId: conversationSenderSideId, receiverSideId: conversationReceiverSideId, isNew: false)
        
        //TAB POSITION
        
        let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
        
        let tabbar = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as! UITabBarController
        
        tabbar.selectedIndex = 3
        
        //VIEW CONTROLLER AND NAV
        
        if let navigation = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
            
            navigation.pushViewController(viewController, animated: true)
                
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
            appDelegate.window?.rootViewController = tabbar
            
        }
        
    }
    
}
