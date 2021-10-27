//
//  serviceYoberDetails.swift
//  Yobli
//
//  Created by Brounie on 13/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class serviceYoberDetails: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var servicePicture: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceSize: UILabel!
    @IBOutlet weak var serviceDate: UILabel!
    @IBOutlet weak var servicePlace: UILabel!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var subPhoto: UIImageView!
    @IBOutlet weak var subName: UILabel!
    
    //MARK: VARs/LETs
    
    var reservation = PFObject(className: "Reservation")
    var subscriber : PFObject?
    var type = ""
    
    let userChatController = ChatMainController()
    var conversationSenderSideId : String?
    var conversationReceiverSideId: String?
    
    //MARK: VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.showHUD(progressLabel: "Cargando...")
        
        self.updateView()
        self.queries()
        
        servicePicture.roundCompleteImage()
        
        subPhoto.roundCompleteImageColor()
        
        self.dismissWithSwipe()
        self.servicePicture.layer.backgroundColor = UIColor.black.cgColor
        self.servicePicture.layer.borderWidth = 1.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
            
            self.dismissHUD(isAnimated: true)
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func contactClient(_ sender: UIButton) {
        
        guard let trueSubscriber = subscriber else{
         
            return
            
        }
        
        self.getIfContact(subscriber: trueSubscriber)
        
    }
    
    @IBAction func getDetailsOfUser(_ sender: UIButton) {
        
        if (subscriber != nil){
            
            guard let user = subscriber else{
                return
            }
            
            let storyboard = UIStoryboard(name: "TabYoberAgenda", bundle: nil)
            
            let viewController = storyboard.instantiateViewController(withIdentifier: "agendaClienteDetails") as? agendaClienteDetails
            
            if let objectId = user.objectId{
                
                viewController?.subscriberId = objectId
                
            }
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        }
        
        
    }
    
    
    
    //MARK: UPDATEVIEW
    
    func updateView(){
        
        if let newName = reservation["name"] as? String{
            self.serviceName.text = newName
        }else{
            self.serviceName.text = nil
        }
        
        if let newDate = reservation["date"] as? Date{
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = Locale(identifier: "es_ES")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            let labelDate = dateFormatter.string(from: newDate)
            
            self.serviceDate.text = labelDate
            
        }else{
            
            self.serviceDate.text = nil
            
        }
        
        if let newLocation = reservation["location"] as? String{
            self.servicePlace.text = newLocation
        }else{
            self.servicePlace.text = nil
        }
        
        if let newPrice = reservation["price"] as? String{
            self.servicePrice.text = newPrice
        }else{
            self.servicePrice.text = nil
        }
        
    }
    
    //MARK: QUERIES
    
    func queries(){
        
        if let newServiceId = reservation["activityId"] as? String{
            let queryService = PFQuery(className: self.type)
            queryService.whereKey("objectId", equalTo: newServiceId)
            queryService.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
                if let error = error {
                    // Log details of the failure
                    self.dismissHUD(isAnimated: true)
                    self.sendErrorType(error: error)
                    
                } else if let object = object {
                    // The find succeeded.
                    if let serviceSize = object["places"] as? Int {
                        self.serviceSize.text = "Ideal para \(serviceSize) persona(s)"
                    }
                    if let imageInformation = object["logo"] as? PFFileObject{
                        imageInformation.getDataInBackground{
                            (imageData: Data?, error: Error?) in
                            if let error = error{
                                print(error.localizedDescription)
                            }else if let imageData = imageData{
                                let image = UIImage(data: imageData)
                                self.servicePicture.image = image
                            }
                        }
                    }else{
                        self.servicePicture.image = nil
                    }
                }
            }
        }
        
        if let recerver = reservation["user"] as? PFObject {
            if let imageInformation = recerver["userPhoto"] as? PFFileObject{
                imageInformation.getDataInBackground{
                    (imageData: Data?, error: Error?) in
                    if let error = error{
                        print(error.localizedDescription)
                    }else if let imageData = imageData{
                        let image = UIImage(data: imageData)
                        self.subPhoto.image = image
                    }
                }
            }else{
                self.subPhoto.image = nil
            }
            if let newName = recerver["name"] as? String{
                self.subName.text = newName
            }else{
                self.subName.text = nil
            }
            self.subscriber = recerver
            self.dismissHUD(isAnimated: true)
        }
    }
    
    //MARK: CONTACT FUNCTIONS
    
    func getIfContact(subscriber: PFObject){
        
        guard let myUserId = PFUser.current()!.objectId, let receiverId = subscriber.objectId else {
            return
        }
        
        userChatController.searchConversationIdInSender(receiverId: receiverId, senderId: myUserId)
        userChatController.searchConversationIdInReceiver(receiverId: receiverId, senderId: myUserId)
        
        userChatController.completionId = { [weak self] result in
            
            self?.conversationSenderSideId = result
            
            self?.userChatController.completionId2 = { [weak self] result2 in
             
                self?.conversationReceiverSideId = result2
                
                if(self?.conversationSenderSideId == nil && self?.conversationReceiverSideId == nil){
                    
                    self?.goToNew(object: subscriber )
                        
                }else{
                        
                    self?.goToExisting(object: subscriber )
                        
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

extension serviceYoberDetails{
    
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
