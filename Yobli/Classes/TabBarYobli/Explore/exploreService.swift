//
//  exploreService.swift
//  Yobli
//
//  Created by Humberto on 8/3/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit
import MBProgressHUD

class  exploreService: UIViewController {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var serviceName: UILabel!
    
    @IBOutlet weak var serviceSize: UILabel!
    
    @IBOutlet weak var servicePrize: UILabel!
    
    @IBOutlet weak var serviceDescription: UILabel!
    
    @IBOutlet weak var serviceImage: UIImageView!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberGoButton: UIButton!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var titleAvailablePlaces: UILabel!
    @IBOutlet weak var availablePlaces: UILabel!
    
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var contactYoberButton: UIButton!
    
    //MARK: VARs/LETs
    
    var service = PFObject(className: "Service")
    
    var yoberObjectId = ""
    var yoberId = ""
    var yoberNamefrId = ""
    var serviceId = ""
    var contact = [String:String]()
    var conversationUserSideId : String?
    var conversationYoberSideId: String?
    
    let userChatController = ChatMainController()
    
    var AppearOnce = true
    
    var places: Int = 0
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.showHUD(progressLabel: "Cargando...")
        
        self.initQuery(id: serviceId)
        
        serviceImage.roundCompleteImageColor()
        yoberPhoto.roundCompleteImageColor()
        yoberGoButton.roundCompleteButton()
        
        self.dismissWithSwipe()
        
        let currentUser = PFUser.current()
        if currentUser?.objectId == self.yoberObjectId {
            self.reserveButton.isHidden = true
            self.contactYoberButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
        if(AppearOnce != true){
        
            self.showHUD(progressLabel: "Actualizando...")
            self.updateView()
            
        }
        
    }
    
//    func searchRegistryUser() {
//
//        let currentUser = PFUser.current()
//
//        print("service: \(self.serviceId)")
//        let querySearchRegistryUser = PFQuery(className: "Reservation")
//        querySearchRegistryUser.whereKey("activityId", contains: self.serviceId)
//        querySearchRegistryUser.findObjectsInBackground { (objects, error) in
//
//            if error == nil, let objects = objects {
//
//                if objects.count == 0 {
//                    print("aun nadie se registra")
//                    self.availablePlaces.text = String(self.places)
//                    self.reserveButton.setTitle("RESERVAR", for: .normal)
//                    self.reserveButton.isUserInteractionEnabled = true
//                    self.reserveButton.setBackgroundImage(UIImage(named: "buttonBG3"), for: .normal)
//                }else{
//
//                    for object in objects {
//                        let user = object["user"] as? PFObject
//                        if user?.objectId == currentUser?.objectId {
//                            print("se registro")
//                            self.reserveButton.setTitle("RESERVADO", for: .normal)
//                            self.reserveButton.isUserInteractionEnabled = false
//                            self.reserveButton.setBackgroundImage(UIImage(named: "buttonBG4"), for: .normal)
//                            let availablePlaces = self.places - objects.count
//                            self.availablePlaces.text = String(availablePlaces)
//                            print("availablePlaces: \(availablePlaces)")
//                        }else{
//
//                            let availablePlaces = self.places - objects.count
//                            self.availablePlaces.text = String(availablePlaces)
//                            print("availablePlaces: \(availablePlaces)")
//                            if availablePlaces <= 0 {
//                                print("ya no ha lugares")
//                                self.reserveButton.setTitle("LUGARES AGOTADOS", for: .normal)
//                                self.reserveButton.isUserInteractionEnabled = false
//                                self.reserveButton.setBackgroundImage(UIImage(named: "buttonBG4"), for: .normal)
//                            }else{
//                                print("hay lugares")
//                                self.reserveButton.setTitle("RESERVAR", for: .normal)
//                                self.reserveButton.isUserInteractionEnabled = true
//                                self.reserveButton.setBackgroundImage(UIImage(named: "buttonBG3"), for: .normal)
//                            }
//                        }
//                    }
//                }
//            }else{
//                print("error")
//            }
//        }
//    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func goToReserve(_ sender: Any) {
        
        let user = PFUser.current()
        
        if user?["locations"] as? [Data] == nil || user?["userIdentification"] as? PFFileObject == nil {
            self.notDIrection()
        } else{
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreAgenda") as? exploreAgenda
            
            if let yober = service["yober"] as? PFObject, let yoberId = yober.objectId{
                
                viewController?.yoberId = yoberId
                viewController?.nameVoluntary = self.serviceName.text ?? ""
                viewController?.serviceObjectId = service.objectId ?? ""
                viewController?.places = self.places
                
            }else{
                print("This should not happen, there is always a userId when a new service is created")
            }

            self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }
    
    @IBAction func getInContact(_ sender: Any) {
        
        if(conversationUserSideId == nil && conversationYoberSideId == nil){
            
            self.createNewConversation()
                
        }else{
                
            self.goToExistingConversation(result: contact)
                
        }
        
    }
    
    @IBAction func search(_ sender: UIButton) {
        
//        let urlCustom = URL(string: "https://yobli.brounieapps.com/Service/\(serviceId)" )
//
//        guard let customURL = urlCustom else {
//
//            print("Couldnt create url")
//
//            return
//
//        }
//
//        let av = UIActivityViewController(activityItems: [customURL], applicationActivities: nil)
//
//        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
        let someText:String = "Yobli"
        let objectsToShare:URL = URL(string: "https://parse.yobli.com/Service/\(serviceId)")!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func goToYober(_ sender: UIButton) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreYoberProfile") as? exploreYoberProfile
        
        viewController?.yoberId = yoberId
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    //MARK: INIT QUERY
    
    func initQuery(id: String){
        
        let queryAlt = PFQuery(className: "Service")
        
        queryAlt.whereKey("objectId", equalTo: id)
        queryAlt.includeKey("yober")
        
        queryAlt.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            
            if let error = error {
                
                self.dismissHUD(isAnimated: true)
                // Log details of the failure
                self.sendErrorTypeAndDismiss(error: error)
                
            } else if let object = object {
                // The find succeeded.
                
                self.service = object
                
                guard let views = self.service["view"] as? Int else{
                    print("This should never happen")
                    return
                }
                
                self.service["view"] = views + 1
                
                self.service.saveInBackground()
                
                self.updateView()
            
            }
            
        }
        
    }
    
    //MARK: UPDATE VIEW
    
    func updateView(){
        
        if let imageInformation = service["logo"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.serviceImage.image = image
                    
                }
                
            }
            
        }else{
            
            self.serviceImage.image = nil
            
        }
        
        if let id = service.objectId{
            
            self.serviceId = id
            
        }
        
        if let newName = service["name"] as? String{
            self.serviceName.text = newName
        }else{
            self.serviceName.text = nil
        }

        if let newDescription = service["description"] as? String{
            self.serviceDescription.text = newDescription
        }else{
            self.serviceDescription.text = nil
        }
        
        if let newCost = service["price"] as? String{
            self.servicePrize.text = newCost
        }else{
            self.serviceName.text = nil
        }

        if let newSize = service["places"] as? NSNumber{
            self.serviceSize.text = "Ideal para " + String(Int(newSize)) + " persona(s)"
            self.places = Int(truncating: newSize)
            //self.searchRegistryUser()
        }else{
            self.serviceDescription.text = nil
        }
        
        if let yober = service["yober"] as? PFObject{
            
            self.getUser(object: yober)
            
        }else{
            print("This should not happen, there is always a userId when a new service is created")
        }
            
    }
    
    //MARK: GET USER
        
    func getUser(object: PFObject){
        
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
            
        if let newName = object["name"] as? String{
            self.yoberNamefrId = newName
            self.yoberName.text = newName
        }else{
            self.yoberName.text = nil
        }
                
        if let newId = object.objectId{
            self.yoberId = newId
            self.contactUser()
            self.getIfContact()
            self.yoberGrade.gradeResults(id: newId)
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
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: true)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func goToExistingConversation(result: [String:String]){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.email, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: false)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
}

extension exploreService{
    
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
