//
//  exploreRegisterPrivateService.swift
//  Yobli
//
//  Created by Brounie on 18/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class exploreRegisterPrivateService: UIViewController{
    
    //MARK: OUTLETS
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var inscriptionDetails: UITableView!
    
    @IBOutlet weak var selectedDateLabel: UILabel!
    
    @IBOutlet weak var paymentButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var paymentSubView: UIView!
    
    @IBOutlet weak var locationSubView: UIView!
    
    @IBOutlet weak var paymentLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: VARs/LETs
    
    var service = PFObject(className: "Service")
    var serviceId = ""
    
    //FOR TABLE IN GENERAL
    
    var buttonSelected = ""
    var selectedButton = UIButton()
    let tableList = UITableView()
    let transparentView = UIView()
    
    //FOR DATE
    
    var result = false
    
    //FOR THE CARD
    
    var cardArray = [PFObject(className: "Card")]
    var cardSelected = false
    
    //FOR THE LOCATION
    
    var locationDataArray = [Data]()
    var locationStructArray = [userAddress]()
    var locationStringArray = [String]()
    var location = ""
    
    //FOR REGISTER
    
    var yoberId = ""
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        self.updateView()
        
        inscriptionDetails.delegate = self
        inscriptionDetails.dataSource = self
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        yoberPhoto.roundCompleteImageColor()
        
        paymentSubView.roundCustomView(divider: 16)
        locationSubView.roundCustomView(divider: 16)
        
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
    
    @IBAction func getPaymentMethod(_ sender: UIButton){
        
        buttonSelected = "card"
        selectedButton = paymentButton
        
        if (cardArray.count > 0){
        
            fillTable(frames: paymentButton.frame, number: cardArray.count)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "No ha registrado algún método de pago, ingrese a su perfil para hacerlo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func displayLocationList(_ sender: Any) {
        
        buttonSelected = "location"
        selectedButton = locationButton
        
        if (locationStringArray.count > 0){
        
            fillTable(frames: locationButton.frame, number: locationStringArray.count)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "No ha registrado una dirección, ingrese a su perfil para hacerlo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func payService(_ sender: Any) {
        
        registerToAService()
        
    }
    
    // MARK: EXTRA FUNCTIONS
    
    func fillAddress(position: Int) -> String{
    
        let result = locationStructArray[position].street + ", " + locationStructArray[position].number + ", " + locationStructArray[position].reference + ", " + locationStructArray[position].colony + ", " + locationStructArray[position].city + ", " + locationStructArray[position].state
        
        return result
        
    }
    
    // MARK: UPDATE VIEW
    
    func updateView(){
        
        self.showHUD(progressLabel: "Cargando...")
        
        //USER PART
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        if let newAddressData = user["locations"] as? [Data]{
            
            var newArrayOfAddressStruct = [userAddress]()
            
            locationDataArray = newAddressData
            
            let decoder = JSONDecoder()
            
            for addressData in locationDataArray{
                
                if let addressStruct = try? decoder.decode(userAddress.self, from: addressData) {
                    
                    newArrayOfAddressStruct.append(addressStruct)
                    
                }
                
            }
            
            locationStructArray = newArrayOfAddressStruct
            
            var newArrayOfAddressString = [String]()
            
            var x = 0
            
            for addressString in locationStructArray{
                
                newArrayOfAddressString.append(fillAddress(position: x))
                if(addressString.selected == true){
                    self.locationLabel.text = fillAddress(position: x)
                    location = fillAddress(position: x)
                }
                
                x = x + 1
                
            }
            
            locationStringArray = newArrayOfAddressString
            
        }
        
        // SERVICE PART
        
        let queryService = PFQuery(className: "Service")
        
        queryService.whereKey("objectId", equalTo: serviceId)
        queryService.includeKey("yober")
        
        queryService.getFirstObjectInBackground { (object, error) in
            
            if error != nil{
                
                self.dismissHUD(isAnimated: true)
                self.dismissViewError()
                
            }else{
                
                if let object = object{
                    
                    self.service = object
                    self.inscriptionDetails.reloadData()
                    
                    guard let yober = self.service["yober"] as? PFObject, let id = yober.objectId else{
                        
                        self.dismissHUD(isAnimated: true)
                        print("This shouldn't happen, to create a service you need a user")
                        
                        return
                    }
                    
                    if let active = self.service["active"] as? Bool{
                        
                        if active == false{
                            
                            self.dismissHUD(isAnimated: true)
                            self.dismissViewError()
                        }
                        
                    }
                    
                    if let date = self.service["date"] as? Date{
                     
                        let actualDate = Date()
                     
                        if date < actualDate{
                            self.dismissHUD(isAnimated: true)
                            self.dismissViewError()
                        }
                        
                        let dateFormatter = DateFormatter()
                        
                        dateFormatter.locale = Locale(identifier: "es_MX")
                        dateFormatter.dateFormat = "EEEE dd, MMMM yyyy"
                        
                        let labelDate = dateFormatter.string(from: date)
                        
                        print(labelDate)
                        
                        self.selectedDateLabel.text = labelDate
                        
                    }
                    
                    self.yoberId = id
                    
                    self.queryUser(object: yober)
                    
                }else{
                    
                    self.dismissHUD(isAnimated: true)
                    
                    print("Is empty")
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: QUERY TO YOBER
    
    func queryUser(object: PFObject){
        
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
            self.yoberName.text = newName
        }else{
            self.yoberName.text = nil
        }
                
        self.yoberGrade.gradeResults(id: self.yoberId)
                    
        self.getCards()
        
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
                                
                                self.paymentLabel.text = "**** **** **** \(last4Digits)"
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
            
            if ( cardSelected == true && location != ""){
                
                self.showHUD(progressLabel: "Realizando Solicitud")
                    
                //GET VARIABLES
                    
                guard let customerId = user["customer_id"] as? String,
                      let correo = user.email,
                      let activityId = service.objectId,
                      let activityName = service["name"] as? String,
                      let activityDate = self.selectedDateLabel.text,
                      let price = self.service["price"] as? String,
                      let cardNumbers = self.paymentLabel.text else{
                    
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
                    
                self.somethingMissing()
                    
            }
            
        }
        
    }
    
    //MARK: CREATE RESERVATION TO SERVICE IN PARSE
    
    func createReservationService(cardlast4: String){
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        let newRegistration = PFObject(className: "Reservation")
                            
        guard let yober = self.service["yober"] as? PFObject,
              let yoberId = yober.objectId,
              let newName = self.service["name"] as? String,
              let newPrice = self.service["price"] as? String,
              let newDuration = self.service["duration"] as? String,
              let newDate = self.service["date"] as? Date,
              let serviceId = self.service.objectId else{
            
            self.dismissHUD(isAnimated: true)
            
            print("Error, falta un dato")
            
            return
            
        }
                                  
        newRegistration["price"] = newPrice
        newRegistration["yober"] = yober
        newRegistration["name"] = newName
        newRegistration["duration"] = newDuration
        newRegistration["date"] = newDate
        newRegistration["location"] = self.location
        newRegistration["user"] = user
        newRegistration["type"] = "Service"
        newRegistration["activityId"] = self.service.objectId
                            
        if let newInscriptions = self.service["inscriptions"] as? Int{
                                
            self.service["inscriptions"] = newInscriptions + 1
            self.service["active"] = false
                                
        }else{
            print("This should not happen, there is always a userId when a new course is created")
        }
                
            
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
    
    //MARK: ERROR FUNCTIONS
    
    func somethingMissing(){
        
        let alert = UIAlertController(title: "ERROR", message: "No se ha seleccionado una tarjeta o método de pago", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    func eventNoAvailable(){
        
        let alert = UIAlertController(title: "ERROR", message: "Usted ya registró este Servicio", preferredStyle: .alert)
                        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
        present(alert, animated: true, completion: nil)
        
    }
    
    func dismissViewError(){
        
        let alert = UIAlertController(title: "ERROR", message: "El servicio ya no está disponible", preferredStyle: .alert)
                    
        let action = UIAlertAction(title: "Cerrar", style: .default){ (_) in
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }
        
        alert.addAction(action)
                    
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: TABLE FUNCTIONS
    
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

//MARK: EXTENSION TABLEVIEW

extension exploreRegisterPrivateService: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "card"){
            
            return cardArray.count
            
        }else if(buttonSelected == "location"){
            
            return locationStringArray.count
            
        }
        
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == inscriptionDetails){
            
            let cell = inscriptionDetails.dequeueReusableCell(withIdentifier: "exploreInscriptionCell4", for: indexPath) as! exploreInscriptionCell
            
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
                        
            default:
                        
                if let newName = service["name"] as? String{
                    cell.information.text = newName
                    cell.icon.image = UIImage(named: "activityIcon")
                }else{
                    cell.information.text = nil
                }
                        
            }
            
            return cell
            
        }else if(buttonSelected == "card"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            guard let cardNumber = cardArray[indexPath.row]["lastFourDigits"] as? String else{
                
                print("Something gone wrong when getting info from the cardArray")
                
                return cell
                
            }
            
            cell.textLabel?.text = "**** **** **** \(cardNumber)"
            cell.textLabel?.font = paymentLabel.font
            
            return cell
            
        }else if(buttonSelected == "location"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = locationStringArray[indexPath.row]
            cell.textLabel?.font = locationLabel.font
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
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
                
                paymentLabel.text = "**** **** **** \(cardNumber)"
                cardSelected = true
                
                removeTableView()
                
            }else{
                
                self.makeCardDefault(position: indexPath.row)
                
                paymentLabel.text = "**** **** **** \(cardNumber)"
                cardSelected = true
                
                removeTableView()
                
            }
            
        }else if(buttonSelected == "location" && tableView != inscriptionDetails ){
            
            location = locationStringArray[indexPath.row]
            locationLabel.text = location
            removeTableView()
            
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

extension exploreRegisterPrivateService{
    
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

extension exploreRegisterPrivateService{
    
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
