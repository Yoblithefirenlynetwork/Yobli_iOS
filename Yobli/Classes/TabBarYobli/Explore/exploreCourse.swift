//
//  exploreCourse.swift
//  Yobli
//
//  Created by Humberto on 8/3/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/* MARK: MAIN INFORMATION
 
 Class exploreCourse
 
 This class is the one that will show the details from the Course selected in the exploreCoursesList or exploreCoursesListDetails
 
 Variables:
 
 Outlet weak var courseImage - ImageView that will display the image of the Course given
 
 Outlet weak var courseTitle - Label that will display the name of the Course given
 
 Outlet weak var courseBriefDesc - Label that will display a BriefDescription of the Course given
 
 Outlet weak var courseTime - Label that will display in a text the Date retrieved of the Course
 
 Outlet weak var courseBriefDetails - Label that will take small details (price, duration and places) of the Course and present them as a single line of text
 
 Outlet weak var courseDescription - TextView that will take a description from the Course
 
 Outlet weak var courseSRequirements - TextView that will take the specialRequirements from the Course
 
 Outlet weak var yoberPhoto - ImageView that will display the profile picture of the Yober that gives the course
 
 Outlet weak var yoberName - Label that will display the name of the Yober that gives the course
 
 Outlet weak var yoberGrade - ImageView that will show the grade of the Yober in a display of blue and white stars
 
 Functions:
 
 viewDidLoad - Main func. It will call the other functions to fill the details of the Course.
 
 updateView - In charge of updating the received data from other views, in this case Course from the exploreCoursesList or exploreCoursesListDetails
 
 getUser - After UpdateView get the userId, the getUser will be used to retrieve the yober that is the one who provides or gives this course.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 singInCourse - function that will send you to the view exploreGeneralInscription so you can register to the Course
 
 */

import Foundation
import UIKit
import Parse
import MBProgressHUD

class exploreCourse: UIViewController{
    
    // MARK: OUTLETS
 
    @IBOutlet weak var courseImage: UIImageView!
    
    @IBOutlet weak var courseTitle: UILabel!
    
    @IBOutlet weak var courseBriefDesc: UILabel!
    
    @IBOutlet weak var courseTime: UILabel!
    
    @IBOutlet weak var courseBriefDetails: UILabel!
    
    @IBOutlet weak var courseDescription: UILabel!
    
    @IBOutlet weak var coursesRequirements: UILabel!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberGoButton: UIButton!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var contactYoberButton: UIButton!
    
    @IBOutlet weak var titleAvailablePlaces: UILabel!
    @IBOutlet weak var availablePlaces: UILabel!
    
    
    //MARK: VARs/LETs
    
    var course = PFObject(className: "Course")
    
    var yoberObjectId = ""
    var yoberId = ""
    var yoberNamefrId = ""
    var courseId = ""
    var contact = [String:String]()
    var conversationUserSideId : String?
    var conversationYoberSideId: String?
    var places: Int = 0
    
    let userChatController = ChatMainController()
    
    var AppearOnce = true
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showHUD(progressLabel: "Cargando...")
        
        self.initQuery(id: courseId)
        
        courseImage.roundCompleteImageColor()
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
        
        if PFUser.current() == nil{
         
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
    
    @IBAction func singInCourse(_ sender: Any){
        
        let user = PFUser.current()
        
        if user?["locations"] as? [Data] == nil || user?["userIdentification"] as? PFFileObject == nil {
            self.notDIrection()
        } else{
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreGeneralInscription") as? exploreGeneralInscription
        
            viewController?.course = course
            viewController?.selection = "Course"
            
            self.navigationController?.pushViewController(viewController!, animated: true)
        }
    }
    
    @IBAction func getInContact(_ sender: Any){
        
        if(conversationUserSideId == nil && conversationYoberSideId == nil){
            
            self.createNewConversation()
                
        }else{
                
            self.goToExistingConversation(result: contact)
                
        }
        
    }
    
    @IBAction func share(_ sender: UIButton) {
        
//        let urlCustom = URL(string: "https://yobli.brounieapps.com/Course/\(courseId)" )
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
        let objectsToShare:URL = URL(string: "https://parse.yobli.com/Course/\(courseId)")!
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
        
        print("curso: \(self.courseId)")
        let querySearchRegistryUser = PFQuery(className: "Reservation")
        querySearchRegistryUser.whereKey("activityId", contains: self.courseId)
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
        
        let queryAlt = PFQuery(className: "Course")
        
        queryAlt.whereKey("objectId", equalTo: id)
        queryAlt.includeKey("yober")
        
        queryAlt.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            
            if let error = error {
                
                self.dismissHUD(isAnimated: true)
                // Log details of the failure
                self.sendErrorTypeAndDismiss(error: error)
                
            } else if let object = object {
                // The find succeeded.
                
                self.course = object
                
                guard let views = self.course["view"] as? Int else{
                    print("This should never happen")
                    return
                }
                
                self.course["view"] = views + 1
                
                self.course.saveInBackground()
                
                self.updateView()
            
            }
            
        }
        
    }
    
    //MARK: UPDATE VIEW
    
    func updateView(){
        
        if let imageInformation = course["logo"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.courseImage.image = image
                }
                
            }
            
        }else{
            
            self.courseImage.image = nil
            
        }
        
        if let id = course.objectId{
            
            self.courseId = id
            
        }
        
        if let newName = course["name"] as? String{
            self.courseTitle.text = newName
        }else{
            self.courseTitle.text = nil
        }
        
        if let newSmallDescription = course["smallDescription"] as? String{
            self.courseBriefDesc.text = newSmallDescription
        }else{
            self.courseBriefDesc.text = nil
        }
        
        //CourseDate
        
        if let newDate = course["date"] as? Date{
            
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
            
            self.courseTime.text = labelDate
            
        }else{
            
            self.courseTime.text = nil
            
        }
        
        //CourseBreafDetails
        
        if let newPrice = course["price"] as? String{
            
            if let newDuration = course["duration"] as? String{
                
                if let newNumberPart = course["places"] as? NSNumber{
                    self.courseBriefDetails.text = newPrice + " | Duración: " + newDuration + " | Lugares: " + newNumberPart.stringValue
                    self.places = Int(truncating: newNumberPart)
                    self.searchRegistryUser()
                }else{
                    self.courseBriefDetails.text = newPrice + " | Duración: " + newDuration
                }
                
            }else{
                
                self.courseBriefDetails.text = newPrice
                
            }
            
        }else if let newDuration = course["duration"] as? String{
            
            self.courseBriefDetails.text = newDuration
            
            if let newNumberPart = course["places"] as? NSNumber{
                self.courseBriefDetails.text = "Duración: " + newDuration + " | Lugares: " + newNumberPart.stringValue
                self.places = Int(truncating: newNumberPart)
                self.searchRegistryUser()
            }else{
                self.courseBriefDetails.text = "Duración: " + newDuration
            }
            
            
        }else if let newNumberPart = course["places"] as? NSNumber{
            
            self.courseBriefDetails.text = "Lugares: " + newNumberPart.stringValue
            self.places = Int(truncating: newNumberPart)
            self.searchRegistryUser()
            
        }else{
            self.courseBriefDetails.text = nil
        }
        
        
        
        if let newDescription = course["description"] as? String{
            self.courseDescription.text = newDescription
        }else{
            self.courseDescription.text = nil
        }
        
        if let newSpecialRequirements = course["specialRequirements"] as? String{
            self.coursesRequirements.text = newSpecialRequirements
        }else{
            self.coursesRequirements.text = nil
        }
        
        if let yober = course["yober"] as? PFObject{
            self.getUser(yober: yober)
        }else{
            print("This should not happen, there is always a userId when a new course is created")
        }
        
    }
    
    //MARK: GET USER
    
    func getUser(yober: PFObject){
        //userPhotoYober
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
            
        if let newName = yober["name"] as? String{
            self.yoberNamefrId = newName
            self.yoberName.text = newName
        }else{
            self.yoberName.text = nil
        }
                
        if let newId = yober.objectId{
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
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYoberAlt(otherUserId: yoberId, otherUserName: yoberNamefrId, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: false)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension exploreCourse{
    
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
