//
//  exploreVoluntary.swift
//  Yobli
//
//  Created by Humberto on 8/4/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class exploreVoluntary: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var voluntaryImage: UIImageView!
    @IBOutlet weak var voluntaryTitle: UILabel!
    @IBOutlet weak var voluntarySmallDesc: UILabel!
    @IBOutlet weak var voluntaryDate: UILabel!
    @IBOutlet weak var voluntaryLocationTime: UILabel!
    @IBOutlet weak var voluntaryLocationExact: UILabel!
    @IBOutlet weak var voluntaryDescription: UITextView!
    @IBOutlet weak var voluntarySpRequirements: UITextView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var voluntaryParticipants: UILabel!
    
    @IBOutlet weak var transportType: UILabel!
    
    @IBOutlet weak var foodAvailable: UILabel!
    
    @IBOutlet weak var voluntaryTransport: UIImageView!
    
    @IBOutlet weak var foodIcon: UIImageView!
    
    @IBOutlet weak var peopleIcon: UIImageView!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberGoButton: UIButton!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var contactYoberButton: UIButton!
    
    @IBOutlet weak var titleAvailablePlaces: UILabel!
    @IBOutlet weak var availablePlaces: UILabel!
    
    //MARK: VARs/LETs
    
    var voluntary = PFObject(className: "Voluntary")
    
    var yoberObjectId = ""
    var yoberId = ""
    var yoberNamefrId = ""
    var voluntaryId = ""
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
        
        self.initQuery(id: voluntaryId)
        
        voluntaryImage.roundCompleteImageColor()
        
        voluntaryTransport.roundCompleteImage()
        voluntaryTransport.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
        
        foodIcon.roundCompleteImage()
        foodIcon.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
        
        peopleIcon.roundCompleteImage()
        peopleIcon.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
    
        yoberPhoto.roundCompleteImageColor()
        
        yoberGoButton.roundCompleteButton()
        
        self.dismissWithSwipe()
        
        let currentUser = PFUser.current()
        if currentUser?.objectId == self.yoberObjectId {
            self.subscribeButton.isHidden = true
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
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func getInContact(_ sender: Any) {
        
        if(conversationUserSideId == nil && conversationYoberSideId == nil){
            
            self.createNewConversation()
                
        }else{
                
            self.goToExistingConversation(result: contact)
                
        }
        
    }
    
    @IBAction func signIn(_ sender: Any) {
        
        let user = PFUser.current()
        
        if user?["locations"] as? [Data] == nil || user?["userIdentification"] as? PFFileObject == nil {
            self.notDIrection()
        } else{
            
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreVoluntaryInscription") as? exploreVoluntaryInscription
        
            viewController?.voluntary = voluntary
        
            self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        
//        let urlCustom = URL(string: "https://yobli.brounieapps.com/Voluntary/\(voluntaryId)" )
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
        let objectsToShare:URL = URL(string: "https://parse.yobli.com/Voluntary/\(voluntaryId)")!
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
    
    func searchRegistryUser() {
     
        let currentUser = PFUser.current()
        
        print("voluntaryId: \(self.voluntaryId)")
        let querySearchRegistryUser = PFQuery(className: "Reservation")
        querySearchRegistryUser.whereKey("activityId", contains: self.voluntaryId)
        querySearchRegistryUser.findObjectsInBackground { (objects, error) in
            
            if error == nil, let objects = objects {
                
                if objects.count == 0 {
                    print("aun nadie se registra")
                    self.availablePlaces.text = String(self.places)
                    self.subscribeButton.setTitle("INSCRIBIRME", for: .normal)
                    self.subscribeButton.isUserInteractionEnabled = true
                    self.subscribeButton.setBackgroundImage(UIImage(named: "buttonBG3"), for: .normal)
                }else{
                    
                    for object in objects {
                        let user = object["user"] as? PFObject
                        if user?.objectId == currentUser?.objectId {
                            print("se registro")
                            self.subscribeButton.setTitle("INSCRITO", for: .normal)
                            self.subscribeButton.isUserInteractionEnabled = false
                            self.subscribeButton.setBackgroundImage(UIImage(named: "buttonBG4"), for: .normal)
                            let availablePlaces = self.places - objects.count
                            self.availablePlaces.text = String(availablePlaces)
                            print("availablePlaces: \(availablePlaces)")
                        }else{
                            
                            let availablePlaces = self.places - objects.count
                            self.availablePlaces.text = String(availablePlaces)
                            print("availablePlaces: \(availablePlaces)")
                            if availablePlaces <= 0 {
                                print("ya no ha lugares")
                                self.subscribeButton.setTitle("LUGARES AGOTADOS", for: .normal)
                                self.subscribeButton.isUserInteractionEnabled = false
                                self.subscribeButton.setBackgroundImage(UIImage(named: "buttonBG4"), for: .normal)
                            }else{
                                print("hay lugares")
                                self.subscribeButton.setTitle("INSCRIBIRME", for: .normal)
                                self.subscribeButton.isUserInteractionEnabled = true
                                self.subscribeButton.setBackgroundImage(UIImage(named: "buttonBG3"), for: .normal)
                            }
                        }
                    }
                }
            }else{
                print("error")
            }
        }
    }
    
    func initQuery(id: String){
        
        let queryAlt = PFQuery(className: "Voluntary")
        
        queryAlt.whereKey("objectId", equalTo: id)
        queryAlt.includeKey("yober")
        
        queryAlt.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            
            if let error = error {
                
                self.dismissHUD(isAnimated: true)
                // Log details of the failure
                self.sendErrorTypeAndDismiss(error: error)
                
            } else if let object = object {
                // The find succeeded.
                
                self.voluntary = object
                
                guard let views = self.voluntary["view"] as? Int else{
                    print("This should never happen")
                    return
                }
                
                self.voluntary["view"] = views + 1
                
                self.voluntary.saveInBackground()
                
                self.updateView()
            
            }
            
        }
        
    }
    
    
    //MARK: UPDATE VIEW
    
    func updateView(){
        
        if let imageInformation = voluntary["logo"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                
                    let image = UIImage(data: imageData)
                    
                    self.voluntaryImage.image = image
                }
                
            }
        
        }else{
            
            self.voluntaryImage.image = nil
            
        }
        
        if let id = voluntary.objectId{
            
            self.voluntaryId = id
            
        }
        
        if let newName = voluntary["name"] as? String{
            self.voluntaryTitle.text = newName
        }else{
            self.voluntaryTitle.text = nil
        }
        
        if let newSmallDescription = voluntary["smallDescription"] as? String{
            self.voluntarySmallDesc.text = newSmallDescription
        }else{
            self.voluntarySmallDesc.text = nil
        }
        
        if let newDate = voluntary["date"] as? Date{
            
            let currentDate = Date()
            
            if( currentDate >= newDate ){
                
                self.subscribeButton.isEnabled = false
                
            }
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            let labelDate = dateFormatter.string(from: newDate)
            
            self.voluntaryDate.text = labelDate
            
        }else{
            
            self.voluntaryDate.text = nil
            
        }
        
        if let newState = voluntary["state"] as? String{
            
            if let newCity = voluntary["city"] as? String{
                
                if let newDuration = voluntary["duration"] as? String{
                    
                    self.voluntaryLocationTime.text = newState + ", " + newCity + " | " + newDuration
                    
                }else{
                    
                    self.voluntaryLocationTime.text = newState + ", " + newCity
                    
                }
                
                
            }else{
                
                if let newDuration = voluntary["duration"] as? String{
                    
                    self.voluntaryLocationTime.text = newState + " | " + newDuration
                    
                }else{
                    
                    self.voluntaryLocationTime.text = newState
                    
                }
                
            }
            
        }else if let newDuration = voluntary["duration"] as? String{
            
            self.voluntaryLocationTime.text = newDuration
            
        }else{
            self.voluntarySpRequirements.text = nil
        }
        
        if let newLocation = voluntary["location"] as? String{
            self.voluntaryLocationExact.text = newLocation
        }else{
            self.voluntaryLocationExact.text = nil
        }
        
        if let newDescription = voluntary["description"] as? String{
            self.voluntaryDescription.text = newDescription
        }else{
            self.voluntaryDescription.text = nil
        }
        
        if let newSpecialRequirements = voluntary["specialRequirements"] as? String{
            self.voluntarySpRequirements.text = newSpecialRequirements
        }else{
            self.voluntarySpRequirements.text = nil
        }
        
        if let newParticipants = voluntary["places"] as? NSNumber{
            self.voluntaryParticipants.text = "Voluntarios: " + newParticipants.stringValue
            self.places = Int(truncating: newParticipants)
            self.searchRegistryUser()
        }else{
            self.voluntaryParticipants.text = nil
        }
        
        if let newTransport = voluntary["transport"] as? Bool{
            
            if(newTransport == true){
                
                transportType.text = "Transporte"
                
            }else{
                
                transportType.text = "Sin Transporte"
                
            }
            
        }
        
        if let newFood = voluntary["food"] as? Bool{
            
            if(newFood == true){
                
                foodAvailable.text = "Comida: Sí"
                
            }else{
                
                foodAvailable.text = "Comida: No"
                
            }
            
        }
        
        if let yober = voluntary["yober"] as? PFObject{
            self.getUser(object: yober)
        }else{
            print("This should not happen, there is always a userId when a new course is created")
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
            
        if let newName = object["name"] as? String {
            self.yoberNamefrId = newName
            self.yoberName.text = newName
        }else{
            self.yoberName.text = nil
        }
                
        if let newId = object.objectId{
            self.yoberId = newId
            self.yoberGrade.gradeResults(id: newId)
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
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYoberAlt(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: true)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func goToExistingConversation(result: [String:String]){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.email, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYoberAlt(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: false)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension exploreVoluntary{
    
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
