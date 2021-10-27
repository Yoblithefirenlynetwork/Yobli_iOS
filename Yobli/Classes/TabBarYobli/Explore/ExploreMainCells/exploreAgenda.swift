//
//  exploreAgenda.swift
//  Yobli
//
//  Created by Brounie on 09/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/* MARK: MAIN INFORMATION
 
 Class exploreAgenda
 
 This class is connected to the view of the same name, this one is given access from the exploreYoberProfile or the exploreService class, in this class the User can check the Agenda of the Yober to contract Service, knowing what days is busy and the first day completely open, this day is marked in a blue color the same as the Yobli logo, this day can be changed for other in the Calendar if the user want another day to contract a service.
 
 This class works with tha additional help of FSCalendar a Library to create a Calendar with different characteristics, including mark dates and change select colors.
 
 Variables:
 
 Outlet weak var yoberAgenda - This is FSCalendar variable that the user will have access, in it the schedulle of the Yober will be display in three different colors: Red (Actual Day), Point Red (Complete Busy or not Available), Purple (Almost full, but can be selectable by the User), Blue Yobli (Empty or selectable)
 
 Outlet weak var yoberPhoto - Display the profile picture of the Yober
 
 Outlet weak var yoberUsername - Display the username of the Yober
 
 Outlet weak var yoberDescription - Display the yoberDescription of the Yober
 
 Outlet weak var yoberGrade - Display the number of stars grading of the Yober
 
 Outlet weak var favoriteIcon - Is a button that will change appearance depending if the Yober presented is a favorite, it can also be press to change the status of a yober from favorite to no favorite.
 
 
 Functions:
 
 viewDidLoad - Main func.
 
 textView - Inside this class will be the specifications on what will happen when the clickable text is press.
 
 logInWFacebook - function connected to the "Iniciar sesion con Facebook" button. Inside this function the user will gain the possiblity to use facebook as a login method combined with parse. In case the user is not registered, it will give the chance to create a new account.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Parse
import FSCalendar
import MBProgressHUD

class exploreAgenda: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var yoberAgenda: FSCalendar!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberUsername: UILabel!
    
    @IBOutlet weak var yoberDescription: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var favoriteIcon: UIButton!
    @IBOutlet weak var reserveButton: UIButton!
    @IBOutlet weak var contactYoberButton: UIButton!
    
    //MARK: VARs/LETs
    
    var places = 0
    var yoberId = "" //yoberId is a var that will receive the Id from the exploreYoberProfile or exploreService
    var emptyColor = 0
    var selectedDate = Date()
    var yoberReady = PFUser()
    var totalOfServices = [PFObject]()
    var totalOfRegisters = [PFObject]()
    var arrayOfDates = [Date]()
    var datesBlocked = [Date]()
    let currenDateTime = Date()
    var daysAvailable = [String]()
    var daysAvailableInt = [Int]()
    var frequency = ""
    
    var yoberName = ""
    var contact = [String:String]()
    var conversationUserSideId : String?
    var conversationYoberSideId: String?
    
    let userChatController = ChatMainController()
    
    var AppearOnce = true
    
    var nameVoluntary = ""
    var serviceObjectId = ""
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.showHUD(progressLabel: "Cargando...")
        
        yoberAgenda.delegate = self
        yoberAgenda.dataSource = self
        yoberAgenda.allowsSelection = true
        
        yoberAgenda.locale = NSLocale.init(localeIdentifier: "es_MX") as Locale
        
        self.updateView()
        
        //This part of code is to make the images appear rounded and to add the blue border, remember to put the Content of the imageView in the storyboards as imageFill
        yoberPhoto.roundCompleteImageColor()
        self.dismissWithSwipe()
        
        let currentUser = PFUser.current()
        if currentUser?.objectId == self.yoberId {
            self.reserveButton.isHidden = true
            self.contactYoberButton.isHidden = true
            self.favoriteIcon.isHidden = true
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
    
    @IBAction func makeFavorite(_ sender: Any) {
        
        let pointer = PFObject(withoutDataWithClassName: "User", objectId: yoberReady.objectId)
        
        if( self.favoriteIcon.image(for: .normal)!.isEqual(UIImage(named: "heartNoSelect") ) ){
            
            self.favoriteIcon.setImage(UIImage(named: "heartSelect"), for: .normal)
            
            let user = PFUser.current()!
            
            user.addUniqueObject(pointer, forKey:"favoriteYobers")
            
            user.saveInBackground()
            
        }else{
            
            self.favoriteIcon.setImage(UIImage(named: "heartNoSelect"), for: .normal)
            
            let user = PFUser.current()!
            
            user.remove(pointer, forKey:"favoriteYobers")
            
            user.saveInBackground()
            
        }
        
    }
    
    @IBAction func getReserveDetails(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreServiceRegisterDetails") as? exploreServiceRegisterDetails
        
        viewController?.dateSelected = selectedDate
        viewController?.yoberId = yoberId
        
        if self.nameVoluntary != "" {
            
            viewController?.nameVoluntary = self.nameVoluntary
            viewController?.serviceObjectId = self.serviceObjectId
            viewController?.places = self.places
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func getInContact(_ sender: Any) {
        
        if(conversationUserSideId == nil && conversationYoberSideId == nil){
            
            self.createNewConversation()
                
        }else{
                
            self.goToExistingConversation(result: contact)
                
        }
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    
    func updateView(){
        
        self.retrieveYober()
            
    }
    
    //MARK: QUERIES
    
    func getAllYoberServices(yober: PFObject){
        
        let queryService = PFQuery(className: "Service")
        
        queryService.whereKey("yober", equalTo: yober)
        queryService.whereKey("active", equalTo: true)
        
        queryService.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                self.totalOfServices = objects
            }
            
        }
        
    }
    
    func getAllReservations(yober: PFObject){
        
        let queryReservation = PFQuery(className: "Reservation")
        
        queryReservation.whereKey("yober", equalTo: yober)
        queryReservation.whereKey("active", equalTo: true)
        
        queryReservation.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                self.totalOfRegisters = objects
                self.getDates(arrayOfRegisters: self.totalOfRegisters)
            }
            
        }
        
    }
    
    func getDates(arrayOfRegisters: [PFObject]){
        
        arrayOfDates = [Date]()
        
        for object in arrayOfRegisters{
            
            if let newDate = object["date"] as? Date{
                
                arrayOfDates.append(newDate)
                
            }
            
        }
        
    }
    
    //MARK: RETRIEVE YOBER INFORMATION
    
    func retrieveYober(){
        
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:yoberId)
        
        queryYober.getFirstObjectInBackground { [self] (object: PFObject?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.dismissHUD(isAnimated: true)
                self.sendErrorTypeAndDismiss(error: error)
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
                
                if let newName = object["name"] as? String {
                    self.yoberName = newName
                    self.yoberUsername.text = newName
                }else{
                    self.yoberUsername.text = nil
                }
                
                if let newId = object.objectId{
                    self.yoberId = newId
                    self.contactUser()
                    self.getIfContact()
                }
                
                if let newDescription = object["userDescription"] as? String{
                    self.yoberDescription.text = newDescription
                }else{
                    self.yoberDescription.text = nil
                }
                
                if let newDates = object["blockedDates"] as? [Date]{
                    
                    datesBlocked = newDates
                    
                }
                
                if let newTsAvailable = object["availableDays"] as? [String]{
                    
                    daysAvailable = newTsAvailable
                    daysAvailableInt = []
                    
                    for myTime in daysAvailable{
                        
                        if(myTime == "LUN"){
                            
                            daysAvailableInt.append(2)
                            
                        }else if(myTime == "MAR"){
                            
                            daysAvailableInt.append(3)
                            
                        }else if(myTime == "MIE"){
                            
                            daysAvailableInt.append(4)
                            
                        }else if(myTime == "JUE"){
                            
                            daysAvailableInt.append(5)
                            
                        }else if(myTime == "VIE"){
                            
                            daysAvailableInt.append(6)
                            
                        }else if(myTime == "SAB"){
                            
                            daysAvailableInt.append(7)
                            
                        }else if(myTime == "DOM"){
                            
                            daysAvailableInt.append(1)
                            
                        }
                        
                    }
                    
                }
                
                if let newFrequency = object["availableFrequency"] as? String{
                    
                    frequency = newFrequency
                    
                }
                
                self.yoberGrade.gradeResults(id: self.yoberId)
                
                self.yoberAgenda.reloadData()
                
                self.yoberReady = object as! PFUser
                
                self.getAllYoberServices(yober: object)
                self.getAllReservations(yober: object)
                
            }
            
            guard let user = PFUser.current() else{
                
                self.sendAlert()
                return
                
            }
            
            if let newYoberArray = user["favoriteYobers"] as? [PFObject]{
                
                let pointer = PFObject(withoutDataWithClassName: "User", objectId: self.yoberReady.objectId)
                
                if( newYoberArray.contains(pointer) ){
                    
                    self.favoriteIcon.setImage(UIImage(named: "heartSelect"), for: .normal)
                    
                }
                else{
                    
                    self.favoriteIcon.setImage(UIImage(named: "heartNoSelect"), for: .normal)
                    
                }
            }else{
                
                self.favoriteIcon.setImage(UIImage(named: "heartNoSelect"), for: .normal)
                
            }
            
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
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberName, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: true)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func goToExistingConversation(result: [String:String]){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberName, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: false)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

// MARK: FSCALENDAR EXTENSION

extension exploreAgenda: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        
        return UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        selectedDate = date
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let dateFormatter = DateFormatter()
            
        dateFormatter.dateFormat = "yyyy/MM/dd"
            
            
        let labelDate1 = dateFormatter.string(from: currenDateTime)
        let labelDate2 = dateFormatter.string(from: date)
            
        if(labelDate1 == labelDate2){
            
            if ( datesBlocked.contains(date) ){
                
                return UIColor.lightGray
                
            }
            
            return UIColor.black
            
        }
        
        if( date > currenDateTime ){
            
            if ( datesBlocked.contains(date) ){
                
                return UIColor.lightGray
                
            }else{
            
                let result = comparisonOfDate(date: date, calendar)
                
                if( result == true ){
                            
                    let color = returnBlackColor(date: date, calendar)
                    
                    return color
                            
                }else{
                            
                    return UIColor.lightGray
                            
                }
                
            }
            
        }else{
            
            return UIColor.lightGray
            
        }
            
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let result = comparisonOfDate(date: date, calendar)
        
        return result
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        return currenDateTime
        
    }
    
    func comparisonOfDate(date: Date, _ calendar: FSCalendar) -> Bool{
        
        if( datesBlocked.contains(date) ){
            
            return false
            
        }
        
        
        if( daysAvailableInt.contains( calendar.gregorian.component(.weekday, from: date) ) ){
            
            if( frequency == "Semanal" ){
                
                if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                    
                    if( calendar.gregorian.component(.weekOfYear, from: currenDateTime) == calendar.gregorian.component(.weekOfYear, from: date) ){
                    
                        return true
                        
                    }else{
                    
                        return false
                    
                    }
                
                }
                
            }else if( frequency ==  "Mensual" ){
                
                if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                    
                    if( calendar.gregorian.component(.month, from: currenDateTime) == calendar.gregorian.component(.month, from: date) ){
                        
                        return true
                        
                    }else{
                    
                        return false
                    
                    }
                
                }
                
            }else if( frequency == "Anual" ){
                
                if( calendar.gregorian.component(.year, from: currenDateTime) == calendar.gregorian.component(.year, from: date) ){
                    
                    return true
                    
                }
                
            }else{
            
                return false
                
            }
            
        }
        
        return false
        
    }
    
    func returnBlackColor(date: Date, _ calendar: FSCalendar) -> UIColor{
        
        switch calendar.gregorian.component(.weekday, from: date) {
        
        case 1:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 2:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 3:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 4:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 5:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 6:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        case 7:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
        default:
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.white
            } else {
                // User Interface is Light
                return UIColor.black
            }
            
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        
        let dateFormatter = DateFormatter()
            
        dateFormatter.dateFormat = "yyyy/MM/dd"
            
            
        let labelDate1 = dateFormatter.string(from: currenDateTime)
        let labelDate2 = dateFormatter.string(from: date)
            
        if(labelDate1 == labelDate2){
            
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                return UIColor.black
            } else {
                // User Interface is Light
                return UIColor.white
            }
            
        }else{
            
            return nil
            
        }
        
    }
    
}

extension exploreAgenda{
    
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
