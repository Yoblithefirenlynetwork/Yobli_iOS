//
//  AlertDetailViewController.swift
//  Yobli
//
//  Created by Francisco javier Moreno Torres on 10/08/21.
//  Copyright © 2021 Brounie. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class AlertDetailViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var activityPicture: UIImageView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activitySmallDescription: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    @IBOutlet weak var activityPlace: UILabel!
    @IBOutlet weak var activityPrice: UILabel!
    @IBOutlet var typeOfSubscriber: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameUserLaber: UILabel!
    
    //MARK: - VARs/LETs
    
    var schedule = Date()
    var type = ""
    var activityId = ""
    var pointerToReservation = ""
    var subscriber : PFObject?
    
    let userChatController = ChatMainController()
    var conversationSenderSideId : String?
    var conversationReceiverSideId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissWithSwipe()
        
        self.getAllAlerts(type: self.type)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PFUser.current() == nil{
            self.sendAlert()
        }
    }
    
    //MARK: - Actions
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func contactUserAction(_ sender: UIButton) {
        
        guard let trueSubscriber = subscriber else{
         
            return
            
        }
        
        self.getIfContact(subscriber: trueSubscriber)
        
    }
    //MARK: - Methods
    
    func getAllAlerts(type: String){
        
        self.showHUD(progressLabel: "Cargando...")
        
        let activityQuery = PFQuery(className: "Alert")
        activityQuery.whereKey("pointerToReservation", contains: self.pointerToReservation)
        
        if self.type == "Service" {
            
            activityQuery.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                    self.dismissHUD(isAnimated: true)
                } else if let objects = objects {
                    for object in objects {
                        let pointerToService = object["pointerToService"] as? PFObject

                        if let imageInformation = pointerToService?["logo"] as? PFFileObject {
                            imageInformation.getDataInBackground {
                                (imageData: Data?, error: Error?) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let imageData = imageData {
                                    let image = UIImage(data: imageData)
                                    self.activityPicture.image = image
                                    self.activityPicture.roundCompleteImageColor()
                                }
                            }
                        } else {
                            self.activityPicture.image = nil
                        }

                        self.activitySmallDescription.text = pointerToService?["description"] as? String
                        
                        //POINTER DE RESERVACIÓN
                        
                        let pointerToReservation = object["pointerToReservation"] as? PFObject

                        let activityQuery = PFQuery(className: "Reservation")
                        activityQuery.whereKey("objectId", contains: pointerToReservation?.objectId)
                        activityQuery.findObjectsInBackground { (objects, error) in
                            if let error = error {
                                // Log details of the failure
                                print(error.localizedDescription)
                            } else if let objects = objects {
                                for object in objects {
                                    self.activityName.text = object["name"] as? String
                                    let date = object["date"] as? Date
                                    let dateString = date?.toString(dateFormat: "EEEE dd, MMMM yyyy")
                                    let duration = object["duration"] as? String


                                    self.activityDate.text =  (dateString ?? "") + " " + (duration ?? "")
                                    self.activityPlace.text = object["location"] as? String
                                    self.activityPrice.text = object["price"] as? String
                                    
                                    let user = object["user"] as? PFObject
                                    
                                    // POINTER DE USUARIO
                                    
                                    let activityQuery = PFQuery(className: "_User")
                                    activityQuery.whereKey("objectId", contains: user?.objectId)
                                    activityQuery.findObjectsInBackground { (objects, error) in
                                        if let error = error {
                                            // Log details of the failure
                                            print(error.localizedDescription)
                                        } else if let objects = objects {
                                            for object in objects {
                                                
                                                self.subscriber = object
                                                if let imageInformation = object["userPhoto"] as? PFFileObject {
                                                    imageInformation.getDataInBackground { (imageData: Data?, error: Error?) in
                                                        if let error = error {
                                                            print(error.localizedDescription)
                                                        } else if let imageData = imageData {
                                                            let image = UIImage(data: imageData)
                                                            self.userImage.image = image
                                                            self.userImage.roundCompleteImageColor()
                                                        }
                                                    }
                                                } else {
                                                    self.userImage.image = nil
                                                }
                                                self.nameUserLaber.text = object["name"] as? String
                                                self.dismissHUD(isAnimated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if self.type == "Course" {
            
            activityQuery.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                    self.dismissHUD(isAnimated: true)
                } else if let objects = objects {
                    
                    for object in objects {
                        
                        let pointerToCourse = object["pointerToCourse"] as? PFObject

                        if let imageInformation = pointerToCourse?["logo"] as? PFFileObject {
                            imageInformation.getDataInBackground {
                                (imageData: Data?, error: Error?) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let imageData = imageData {
                                    let image = UIImage(data: imageData)
                                    self.activityPicture.image = image
                                    self.activityPicture.roundCompleteImageColor()
                                }
                            }
                        } else {
                            self.activityPicture.image = nil
                        }

                        self.activitySmallDescription.text = pointerToCourse?["description"] as? String
                        self.activityName.text = pointerToCourse?["name"] as? String
                        
                        let date = pointerToCourse?["date"] as? Date
                        let dateString = date?.toString(dateFormat: "EEEE dd, MMMM yyyy")
                        let duration = pointerToCourse?["duration"] as? String


                        self.activityDate.text =  (dateString ?? "") + " " + (duration ?? "")
                        self.activityPlace.text = pointerToCourse?["location"] as? String
                        self.activityPrice.text = pointerToCourse?["price"] as? String
                        
                        
                        //POINTER DE RESERVACIÓN
                        
                        let pointerToReservation = object["pointerToReservation"] as? PFObject

                        let activityQuery = PFQuery(className: "Reservation")
                        activityQuery.whereKey("objectId", contains: pointerToReservation?.objectId)
                        activityQuery.findObjectsInBackground { (objects, error) in
                            if let error = error {
                                // Log details of the failure
                                print(error.localizedDescription)
                            } else if let objects = objects {
                                for object in objects {
                                    let user = object["user"] as? PFObject
                                    
                                    // POINTER DE USUARIO
                                    
                                    let activityQuery = PFQuery(className: "_User")
                                    activityQuery.whereKey("objectId", contains: user?.objectId)
                                    activityQuery.findObjectsInBackground { (objects, error) in
                                        if let error = error {
                                            // Log details of the failure
                                            print(error.localizedDescription)
                                        } else if let objects = objects {
                                            for object in objects {
                                                self.subscriber = object
                                                if let imageInformation = object["userPhoto"] as? PFFileObject {
                                                    imageInformation.getDataInBackground { (imageData: Data?, error: Error?) in
                                                        if let error = error {
                                                            print(error.localizedDescription)
                                                        } else if let imageData = imageData {
                                                            let image = UIImage(data: imageData)
                                                            self.userImage.image = image
                                                            self.userImage.roundCompleteImageColor()
                                                        }
                                                    }
                                                } else {
                                                    self.userImage.image = nil
                                                }
                                                
                                                self.nameUserLaber.text = object["name"] as? String
                                                self.dismissHUD(isAnimated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if self.type == "Voluntary" {
            
            activityQuery.findObjectsInBackground { (objects, error) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                    self.dismissHUD(isAnimated: true)
                } else if let objects = objects {
                    
                    for object in objects {
                        
                        let pointerToVolunrary = object["pointerToVoluntary"] as? PFObject

                        if let imageInformation = pointerToVolunrary?["logo"] as? PFFileObject {
                            imageInformation.getDataInBackground {
                                (imageData: Data?, error: Error?) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let imageData = imageData {
                                    let image = UIImage(data: imageData)
                                    self.activityPicture.image = image
                                    self.activityPicture.roundCompleteImageColor()
                                }
                            }
                        } else {
                            self.activityPicture.image = nil
                        }

                        self.activitySmallDescription.text = pointerToVolunrary?["description"] as? String
                        self.activityName.text = pointerToVolunrary?["name"] as? String
                        
                        let date = pointerToVolunrary?["date"] as? Date
                        let dateString = date?.toString(dateFormat: "EEEE dd, MMMM yyyy")
                        let duration = pointerToVolunrary?["duration"] as? String


                        self.activityDate.text =  (dateString ?? "") + " " + (duration ?? "")
                        self.activityPlace.text = pointerToVolunrary?["location"] as? String
                        self.activityPrice.isHidden = true
                        
                        //POINTER DE RESERVACIÓN
                        
                        let pointerToReservation = object["pointerToReservation"] as? PFObject

                        let activityQuery = PFQuery(className: "Reservation")
                        activityQuery.whereKey("objectId", contains: pointerToReservation?.objectId)
                        activityQuery.findObjectsInBackground { (objects, error) in
                            if let error = error {
                                // Log details of the failure
                                print(error.localizedDescription)
                            } else if let objects = objects {
                                for object in objects {
                                    let user = object["user"] as? PFObject
                                    
                                    // POINTER DE USUARIO
                                    
                                    let activityQuery = PFQuery(className: "_User")
                                    activityQuery.whereKey("objectId", contains: user?.objectId)
                                    activityQuery.findObjectsInBackground { (objects, error) in
                                        if let error = error {
                                            // Log details of the failure
                                            print(error.localizedDescription)
                                        } else if let objects = objects {
                                            for object in objects {
                                                self.subscriber = object
                                                if let imageInformation = object["userPhoto"] as? PFFileObject {
                                                    imageInformation.getDataInBackground { (imageData: Data?, error: Error?) in
                                                        if let error = error {
                                                            print(error.localizedDescription)
                                                        } else if let imageData = imageData {
                                                            let image = UIImage(data: imageData)
                                                            self.userImage.image = image
                                                            self.userImage.roundCompleteImageColor()
                                                        }
                                                    }
                                                } else {
                                                    self.userImage.image = nil
                                                }
                                                
                                                self.nameUserLaber.text = object["name"] as? String
                                                self.dismissHUD(isAnimated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else{
            print("error en el tipo de servicio")
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
