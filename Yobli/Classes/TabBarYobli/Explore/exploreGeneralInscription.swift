//
//  exploreCourseInscription.swift
//  Yobli
//
//  Created by Brounie on 28/08/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class exploreGeneralInscription
 
 This class will let the user get in a Course or Contrat a Service, depending on what is the previous view they come from (exploreCourse or exploreServiceRegisterDetails)
 
 Variables:
 
 Outlet weak var yoberPhoto - ImageView that will display the profile picture of the Yober that gives the course
 
 Outlet weak var yoberName - Label that will display the name of the Yober that gives the course
 
 Outlet weak var yoberGrade - ImageView that will show the grade of the Yober in a display of blue and white stars
 
 Outlet weak var inscriptionDate - Label that will show the day the Service or Course will be given
 
 Outlet weak var inscriptionDetails - TableView that will show small details of the Service or Course like, price, duration, size, etc.
 
 Outlet weak var paymentMethod - Button that will display a table with the paymentMethods of the user
 
 Outlet weak var paymentMethodLabel - Label that will be rewritted with the paymentMethod of the user selected
 
 Functions:
 
 */

import Foundation
import UIKit
import Parse
import MBProgressHUD

class exploreGeneralInscription: UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var inscriptionDate: UILabel!
    
    @IBOutlet weak var inscriptionDetails: UITableView!
    
    @IBOutlet weak var paymentMethod: UIButton!
    
    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: VARs/LETs
    
    var course = PFObject(className: "Course")
    var service = PFObject(className: "Service")
    
    var reservationDone = false
    var selection = ""
    var location = ""
    var time = ""
    var dateSelected = Date()
    var dateComplete = Date()
    
    var buttonSelected = ""
    var cardArray = [PFObject(className: "Card")]
    var cardSelected = false
    
    var selectedButton = UIButton()
    let tableList = UITableView()
    let transparentView = UIView()
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        if(selection == "Course"){
            
            guard let user = PFUser.current() else{
                
                self.sendAlert()
                return
                
            }
            
            guard let courseId = course.objectId, let yober = course["yober"] as? PFObject else{
                
                print("Something is wrong")
                
                return
                
            }
            
            self.compareRegistrations(keyFromActivity: courseId, user: user, yober: yober)
            
        }
        
        inscriptionDetails.delegate = self
        inscriptionDetails.dataSource = self
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        yoberPhoto.roundCompleteImageColor()
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func payCourse(_ sender: Any) {
        
        if(selection == "Course"){
            
            self.registerToACourse()
            
        }else if(selection == "Service"){
                
            self.registerToAService()
            
        }
    }
    
    @IBAction func getPaymentMethod(_ sender: UIButton){
        
        buttonSelected = "card"
        selectedButton = paymentMethod
        
        if (cardArray.count > 0){
        
            fillTable(frames: paymentMethod.frame, number: cardArray.count)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "No ha registrado algún método de pago, ingrese a su perfil para hacerlo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    // MARK: UPDATE VIEW
    
    func updateView(){
        
        self.showHUD(progressLabel: "Cargando información")
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        if(selection == "Service"){
            
            self.editTime()
            
            let labelDate = dateFormatter.string(from: dateComplete)
            
            self.inscriptionDate.text = labelDate
            
            if let yober = self.service["yober"] as? PFObject{
                self.getUser(object: yober)
            }else{
                print("This should not happen, there is always a userId when a new service is created")
            }
            
        }else if(selection == "Course"){
            
            if let newDate = self.course["date"] as? Date{
                
                let labelDate = dateFormatter.string(from: newDate)
                
                self.inscriptionDate.text = labelDate
                
            }
            
            if let yober = self.course["yober"] as? PFObject {
                self.getUser(object: yober)
            }else{
                print("This should not happen, there is always a userId when a new course is created")
            }
            
        }
        
    }
    
    //MARK: GET CARDS
    
    func getCards(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        let cardsQuery = PFQuery(className: "Card")
        cardsQuery.whereKey("user", equalTo: user )
        cardsQuery.order(byDescending: "createdAt")
        
        cardsQuery.findObjectsInBackground { (results, error) in
            
            if let error = error{
                
                self.dismissHUD(isAnimated: true)
                
                let nsError = error as NSError
                
                switch (nsError.code) {
                case 101: //No results matched the query
                    let alert = UIAlertController(title: "ERROR", message: "No ha registrado algún método de pago, ingrese a su perfil para hacerlo", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                                    
                    self.present(alert, animated: true, completion: nil)
                default:
                    self.sendErrorType(error: error)
                }
                
            }else if let results = results{
                
                self.cardArray = results
                
                for card in self.cardArray{
                    
                    if let isDefault = card["default"] as? Bool{
                        
                        if isDefault == true{
                            
                            if let last4Digits = card["lastFourDigits"] as? String{
                                
                                self.paymentMethodLabel.text = "**** **** **** \(last4Digits)"
                                self.cardSelected = true
                                
                                break
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                self.dismissHUD(isAnimated: true)
                
            }
            
        }
        
    }
    
    //MARK: COMPARE REGISTRATIONS
    
    func compareRegistrations(keyFromActivity: String, user: PFObject, yober: PFObject){
        
        let queryReservation = PFQuery(className: "Reservation")
        
        queryReservation.whereKey("activityId", equalTo: keyFromActivity)
        queryReservation.whereKey("type", contains: "Course")
        queryReservation.whereKey("yober", equalTo: yober)
        queryReservation.whereKey("user", equalTo: user)
        queryReservation.whereKey("active", equalTo: true)
        
        queryReservation.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            
            if let error = error {
                // The query failed
                print(error.localizedDescription)
            } else if object != nil {
                // The query succeeded with a matching result
                self.reservationDone = true
                
            }
            
        }
        
    }
    
    // MARK: GET YOBER INFO
    
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
            
            if let newName = object["name"] as? String{
                self.yoberName.text = newName
            }else{
                self.yoberName.text = nil
            }
                
            guard let newId = object.objectId else{
                    
                print("This should never happen, a user always has an objectId")
                    
                return
                    
            }
                
            self.yoberGrade.gradeResults(id: newId)
                
            self.getCards()
                
        }
        
    }
    
    //MARK: TIME FUNCTIONS
    
    func editTime(){
        
        //MAKING THE TIME
        
        //MAKING THE TIME
        let newTime = time.replacingOccurrences(of: ":00", with: "")
        var timeDate = 0
        
        if let actualTime = Int(newTime) {
            
            timeDate = actualTime
            
        }
        
        let date = Calendar.current.date(bySettingHour: timeDate, minute: 0, second: 0, of: dateSelected)!
        
        dateComplete = date
        
    }
    
    //MARK: REGISTER TO A COURSE
    
    func registerToACourse(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        guard let actualId = user.objectId, let yober = course["yober"] as? PFObject, let yoberId = yober.objectId else{
            
            
            self.customError(description: "Algo salió mal al momento de obtener su o la id del creador")
            return
            
        }
        
        if( actualId == yoberId ){
            
            self.customError(description: "El creador y el usuario son el mismo, no puede unirse")
            
        }else{
            
            if( cardSelected == true ){
                
                self.course.fetchInBackground { (result, error) in
                    
                    if let error = error{
                        
                        self.sendErrorType(error: error)
                        
                    }else if let result = result{
                        
                        self.course = result
                        
                        guard let inscriptionsDone = self.course["inscriptions"] as? Int, let numberLimit = self.course["places"] as? Int else{
                            
                            print("This should not happen, it should have a value")
                            
                            return
                            
                        }
                        
                        if(inscriptionsDone < numberLimit){
                            
                            if( self.reservationDone == false ){
                                
                                self.showHUD(progressLabel: "Realizando Solicitud")
                                    
                                //GET VARIABLES
                                    
                                guard let customerId = user["customer_id"] as? String,
                                      let correo = user.email,
                                      let activityId = self.course.objectId,
                                      let activityName = self.course["name"] as? String,
                                      let activityDate = self.inscriptionDate.text,
                                      let price = self.course["price"] as? String,
                                      let cardNumbers = self.paymentMethodLabel.text else{
                                    
                                        self.dismissHUD(isAnimated: true)
                                            
                                        print("Something is wrong or something is not complete")
                                            
                                        return
                                        
                                }
                                    
                                let priceWithOutTag = price.replacingOccurrences(of: "$", with: "")
                                let priceWithOutMXN = priceWithOutTag.replacingOccurrences(of: "MXN", with: "")
                                let priceWithOutEmptySpaces = priceWithOutMXN.replacingOccurrences(of: " ", with: "")
                                    
                                guard let truePrice = Double(priceWithOutEmptySpaces) else{
                                        
                                    self.dismissHUD(isAnimated: true)
                                        
                                    print("In the price something went wrong")
                                    
                                    return
                                        
                                }
                                    
                                let activityType = "Course"
                                    
                                //GET PARAMS
                                    
                                let params = NSMutableDictionary()
                                        
                                params.setObject(correo, forKey: "email" as NSCopying)
                                params.setObject(truePrice, forKey: "amount" as NSCopying)
                                params.setObject(customerId, forKey: "customer_id" as NSCopying)
                                params.setObject(activityId, forKey: "activity_id" as NSCopying)
                                params.setObject(activityType, forKey: "activity_type" as NSCopying)
                                params.setObject(activityName, forKey: "activity_name" as NSCopying)
                                params.setObject(activityDate, forKey: "activity_date" as NSCopying)
                                
                                //DO THE CHARGE TO CONEKTA
                                    
                                PFCloud.callFunction(inBackground: "createConektaCharge", withParameters: params as [NSObject : AnyObject], block:{ (results: Any?, error: Error?)  -> Void in
                                        
                                    if let error = error{
                                            
                                        self.dismissHUD(isAnimated: true)
                                            
                                        self.sendErrorFromConekta(error: error)
                                            
                                    }else if let results = results{
                                            
                                        print("Resultado: \(results)")
                                        
                                        self.createReservationCourse(cardlast4: cardNumbers)
                                            
                                    }
                                        
                                })
                                
                            }else{
                                
                                self.eventAllReadyRegister()
                                
                            }
                            
                        }else{
                            
                            self.eventFull()
                            
                        }
                        
                        
                    }
                    
                }
                
            }else{
                
                self.cardNoPresent()
                
            }
        
        }
        
    }
    
    //MARK: REGISTER TO A SERVICE
    
    func registerToAService(){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        guard let actualId = user.objectId, let yober = service["yober"] as? PFObject, let yoberId = yober.objectId else{
            
            
            self.customError(description: "Algo salió mal al momento de obtener su o la id del creador")
            return
            
        }
        
        if( actualId == yoberId ){
            
            self.customError(description: "El creador y el usuario son el mismo, no puede unirse")
            
        }else{
            
            if( cardSelected == true ){
                
                self.showHUD(progressLabel: "Realizando Solicitud")
                    
                //GET VARIABLES
                    
                guard let customerId = user["customer_id"] as? String,
                      let correo = user.email,
                      let activityId = service.objectId,
                      let activityName = service["name"] as? String,
                      let activityDate = self.inscriptionDate.text,
                      let price = self.service["price"] as? String,
                      let cardNumbers = self.paymentMethodLabel.text else{
                    
                        self.dismissHUD(isAnimated: true)
                        
                        print("Something is wrong or something is not complete")
                        
                        return
                        
                    }
                    
                let priceWithOutTag = price.replacingOccurrences(of: "$", with: "")
                let priceWithOutMXN = priceWithOutTag.replacingOccurrences(of: "MXN", with: "")
                let priceWithOutEmptySpaces = priceWithOutMXN.replacingOccurrences(of: " ", with: "")
                    
                guard let truePrice = Double(priceWithOutEmptySpaces) else{
                        
                    self.dismissHUD(isAnimated: true)
                        
                    print("In the price something went wrong")
                    
                    return
                        
                }
                    
                let activityType = "Service"
                    
                //GET PARAMS
                    
                let params = NSMutableDictionary()
                        
                params.setObject(correo, forKey: "email" as NSCopying)
                params.setObject(truePrice, forKey: "amount" as NSCopying)
                params.setObject(customerId, forKey: "customer_id" as NSCopying)
                params.setObject(activityId, forKey: "activity_id" as NSCopying)
                params.setObject(activityType, forKey: "activity_type" as NSCopying)
                params.setObject(activityName, forKey: "activity_name" as NSCopying)
                params.setObject(activityDate, forKey: "activity_date" as NSCopying)
                
                //DO THE CHARGE TO CONEKTA
                    
                PFCloud.callFunction(inBackground: "createConektaCharge", withParameters: params as [NSObject : AnyObject], block:{ (results: Any?, error: Error?)  -> Void in
                        
                    if let error = error{
                            
                        self.dismissHUD(isAnimated: true)
                            
                        self.sendErrorFromConekta(error: error)
                            
                    }else if let results = results{
                            
                        print("Resultado: \(results)")
                        
                        self.createReservationService(cardlast4: cardNumbers)
                            
                    }
                        
                })
                
            }else{
                
                self.cardNoPresent()
                
            }
        
        }
        
    }
    
    
    //MARK: RESERVATION TO SERVICE
    
    func createReservationService(cardlast4: String){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        self.service.fetchInBackground { (result, error) in
            
            if let error = error{
                
                self.dismissHUD(isAnimated: true)
                
                self.sendErrorType(error: error)
                
            }else if let result = result{
                
                self.service = result
                
                let newRegistration = PFObject(className: "Reservation")
                
                guard let yober = self.service["yober"] as? PFObject,
                      let yoberId = yober.objectId,
                      let newName = self.service["name"] as? String,
                      let newPrice = self.service["price"] as? String,
                      let newDuration = self.service["duration"] as? String,
                      let newInscriptions = self.service["inscriptions"] as? Int,
                      let serviceId = self.service.objectId else{
                    
                    self.dismissHUD(isAnimated: true)
                    print("Something went wrong here, it shouldnt, all this information should be there when creating a  service")
                    
                    return
                    
                }
                                        
                newRegistration["yober"] = yober
                newRegistration["name"] = newName
                newRegistration["price"] = newPrice
                newRegistration["duration"] = newDuration
                newRegistration["date"] = self.dateComplete
                newRegistration["location"] = self.location
                newRegistration["user"] = user
                newRegistration["type"] = "Service"
                newRegistration["activityId"] = self.service.objectId
                
                newRegistration["active"] = true
                newRegistration["grade"] = false
                                    
                self.service["inscriptions"] = newInscriptions + 1
                
                newRegistration.saveInBackground { (success: Bool?, error: Error?) in
                    
                    self.dismissHUD(isAnimated: true)
                        
                    if let error = error {
                        // The query failed
                        self.sendErrorType(error: error)
                    } else if success != nil {
                        // The query succeeded with a matching result
                        if let newId = newRegistration.objectId{
                                
                            let pointer = PFObject(withoutDataWithClassName: "Reservation", objectId: newId)
                            
                            let userSaving = PFUser.current()!
                                
                            userSaving.addUniqueObject(pointer, forKey:"registerEvents")
                            
                            userSaving.saveInBackground()
                                
                            self.service.saveInBackground()
                            
                            NotificationHandler.createAlertForReservation(receiver: yober, receiverId: yoberId, notificationType: "Reservation", activityId: serviceId, activityType: "Service", activityName: newName, pointerToReservation: newRegistration)
                            
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "exploreRegistrationSuccess") as? exploreRegistrationSuccess
                                    
                            viewController?.typeOfActivity = "Service"
                            viewController?.reservation = newRegistration
                            viewController?.cardSelected = cardlast4

                            self.navigationController?.pushViewController(viewController!, animated: true)
                                
                        }
                            
                    }
                        
                }
                
            }
            
        }
        
    }
    
    //MARK: RESERVATION TO COURSE
    
    func createReservationCourse(cardlast4: String){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        self.course.fetchInBackground { (result, error) in
            
            if let error = error{
                
                self.dismissHUD(isAnimated: true)
                
                self.sendErrorType(error: error)
                
            }else if let result = result{
                
                self.course = result
                
                let newRegistration = PFObject(className: "Reservation")
                            
                guard let yober = self.course["yober"] as? PFObject,
                      let yoberId = yober.objectId,
                      let newName = self.course["name"] as? String,
                      let newTime = self.course["duration"] as? String,
                      let newDate = self.course["date"] as? Date,
                      let newLocation = self.course["location"] as? String,
                      let newPrice = self.course["price"] as? String,
                      let newInscriptions = self.course["inscriptions"] as? Int,
                      let courseId = self.course.objectId else{
                    
                    print("This should happen, course should have all this fields")
                    self.dismissHUD(isAnimated: true)
                    
                    return
                    
                }
                                
                newRegistration["yober"] = yober
                newRegistration["name"] = newName
                newRegistration["duration"] = newTime
                newRegistration["location"] = newLocation
                newRegistration["price"] = newPrice
                newRegistration["date"] = newDate
                newRegistration["user"] = user
                newRegistration["type"] = "Course"
                newRegistration["activityId"] = self.course.objectId
                
                newRegistration["active"] = true
                newRegistration["grade"] = false
                
                self.course["inscriptions"] = newInscriptions + 1
                
                newRegistration.saveInBackground { (success: Bool?, error: Error?) in
                    
                    self.dismissHUD(isAnimated: true)
                    
                    if let error = error {
                        // The query failed
                        self.sendErrorType(error: error)
                    } else if success != nil {
                        // The query succeeded with a matching result
                        if let newId = newRegistration.objectId{
                            
                            let pointer = PFObject(withoutDataWithClassName: "Reservation", objectId: newId)
                            
                            let userSaving = PFUser.current()!
                            
                            userSaving.addUniqueObject(pointer, forKey:"registerEvents")
                            
                            userSaving.saveInBackground()
                            
                            self.course.saveInBackground()
                            
                            NotificationHandler.createAlertForReservation(receiver: yober, receiverId: yoberId, notificationType: "Reservation", activityId: courseId, activityType: "Course", activityName: newName, pointerToReservation: newRegistration)
                            
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "exploreRegistrationSuccess") as? exploreRegistrationSuccess
                            
                            viewController?.typeOfActivity = "Course"
                            viewController?.reservation = newRegistration
                            viewController?.cardSelected = cardlast4

                            self.navigationController?.pushViewController(viewController!, animated: true)
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    //MARK: ERROR FUNC SITUATIONS
    
    func cardNoPresent(){
        
        let alert = UIAlertController(title: "ERROR", message: "Usted no ha seleccionado un método de pago", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    func eventFull(){
        
        let alert = UIAlertController(title: "ERROR", message: "Este curso ya llego a su límite", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    func eventAllReadyRegister(){
        
        let alert = UIAlertController(title: "ERROR", message: "Ya se registró a este Curso", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: TABLE FUNCTIONS
    
    func fillTable(frames: CGRect, number: Int){
        
        if( self.scrollView.frame.height > CGFloat(650) ){
            
            self.contentViewHeight.constant = self.scrollView.frame.height
            self.mainView.layoutIfNeeded()
            
        }
        
        transparentView.frame = self.contentView.frame
        self.contentView.addSubview(transparentView)
        
        if #available(iOS 13.0, *) {
            transparentView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.02)
        } else {
            // Fallback on earlier versions
            transparentView.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTableView) )
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        
        self.contentView.addSubview(tableList)
        
        tableList.layer.cornerRadius = 0.5
        
        tableList.reloadData()
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTableView))
        
        //self.view.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0.02
            
            if ( number >= 3){
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 150)
                
            }else{
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(number * 50))
                
            }
            
            
            
        }, completion: nil)
        
        
    }
    
    @objc func removeTableView(){
        
        let frames = selectedButton.frame
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0
            
            self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
            
            }, completion: nil)
        
    }
    
}

//MARK: TABLEVIEW EXTENSION

extension exploreGeneralInscription: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "card"){
            
            return cardArray.count
            
        }
        
        return 4
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == inscriptionDetails){
            
            let cell = inscriptionDetails.dequeueReusableCell(withIdentifier: "exploreInscriptionCell1", for: indexPath) as! exploreInscriptionCell
            
            if(selection == "Course"){
                
                switch indexPath.row{
                    
                case 1:
                    
                    if let newCost = course["price"] as? String{
                        cell.information.text = newCost
                        cell.icon.image = UIImage(named: "priceIcon")
                    }else{
                        cell.information.text = nil
                    }
                    
                case 2:
                    
                    if let newTime = course["duration"] as? String{
                        cell.information.text = newTime
                        cell.icon.image = UIImage(named: "timeIcon")
                    }else{
                        cell.information.text = nil
                    }
                    
                case 3:
                    
                    if let newLocation = course["location"] as? String{
                        cell.information.text = newLocation
                        cell.icon.image = UIImage(named: "zoneIcon")
                    }else{
                        cell.information.text = nil
                    }
                    
                    
                default:
                    
                    if let newName = course["name"] as? String{
                        cell.information.text = newName
                        cell.icon.image = UIImage(named: "activityIcon")
                    }else{
                        cell.information.text = nil
                    }
                    
                        
                }
                
                
            }else if(selection == "Service"){
                
                switch indexPath.row{
                        
                case 1:
                        
                    if let newCost = service["price"] as? String{
                        cell.information.text = newCost
                        cell.icon.image = UIImage(named: "priceIcon")
                    }else{
                        cell.information.text = nil
                    }
                        
                case 2:
                        
                    if let newTime = service["duration"] as? String{
                        cell.information.text = newTime
                        cell.icon.image = UIImage(named: "timeIcon")
                    }else{
                        cell.information.text = nil
                    }
                        
                case 3:
                        
                    cell.information.text = location
                    cell.icon.image = UIImage(named: "zoneIcon")
                        
                default:
                        
                    if let newName = service["name"] as? String{
                        cell.information.text = newName
                        cell.icon.image = UIImage(named: "activityIcon")
                    }else{
                        cell.information.text = nil
                    }
                        
                }
                
            }
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            guard let cardNumber = cardArray[indexPath.row]["lastFourDigits"] as? String else{
                
                print("Something gone wrong when getting info from the cardArray")
                
                return cell
                
            }
            
            cell.textLabel?.text = "**** **** **** \(cardNumber)"
            cell.textLabel?.font = paymentMethodLabel.font
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "card" && tableView != inscriptionDetails){
            
            guard let cardNumber = cardArray[indexPath.row]["lastFourDigits"] as? String, let defaultCard = cardArray[indexPath.row]["default"] as? Bool else{
                
                print("Something gone wrong when getting info from the cardArray")
                
                return
                
            }
            
            if defaultCard == true{
                
                paymentMethodLabel.text = "**** **** **** \(cardNumber)"
                cardSelected = true
                
                removeTableView()
                
            }else{
                
                self.makeCardDefault(position: indexPath.row)
                
                paymentMethodLabel.text = "**** **** **** \(cardNumber)"
                cardSelected = true
                
                removeTableView()
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if( tableView != inscriptionDetails ){
            
            return 40
            
        }else{
        
            return 60
            
        }
        
    }
    
}

//MARK: MAKE A DEFAULT CARD EXTENSION

extension exploreGeneralInscription{
    
    func makeCardDefault(position: Int){
        
        self.showHUD(progressLabel: "Actualizando método de pago...")
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        //Array to set everything to false and true
        
        var x = 0
        
        for card in self.cardArray{
            
            if( x == position  ){
                
                card["default"] = true
                
            }else{
                
                card["default"] = false
                
            }
            
            x = x + 1
            
        }
        
        //Set the card to default in parse and save All with the changes after
        
        let params = NSMutableDictionary()
        
        let card = self.cardArray[position]
        
        if let cardId = card["cardTokenId"] as? String{
            
            params.setObject(cardId, forKey: "source_id" as NSCopying)
            
            if let customerId = user["customer_id"] as? String{
                
                params.setObject(customerId, forKey: "customer_id" as NSCopying)
                
                PFCloud.callFunction(inBackground: "updateConektaCustomerDefaultSource", withParameters: params as [NSObject : AnyObject], block:{ (results, error)  -> Void in
                    
                    if let error = error{
                        
                        print("Error during default card")
                        
                        self.dismissHUD(isAnimated: true)
                        
                        self.sendErrorFromConekta(error: error)
                        
                    }else{
                        
                        PFObject.saveAll(inBackground: self.cardArray) { (result, error) in
                            
                            if let error = error{
                                
                                print("Error during saving all cards")
                                
                                self.dismissHUD(isAnimated: true)
                                
                                self.sendErrorType(error: error)
                                
                            }else{
                                
                                self.getCards()
                                
                            }
                            
                        }
                        
                    }
                    
                })
            
            }else{
                
                print("This shouldnt happen, but if it does we need to create a customer_id")
                
            }
            
        }
        
        
    }
    
}

//MARK: SHOW HUD EXTENSION

extension exploreGeneralInscription{
    
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
