//
//  exploreServiceRegisterDetails.swift
//  Yobli
//
//  Created by Brounie on 09/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

class exploreServiceRegisterDetails: UIViewController{
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberName: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var selectedDateLabel: UILabel!
    
    @IBOutlet var serviceButton: UIButton!
    
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var serviceSubView: UIView!
    
    @IBOutlet weak var timeSubView: UIView!
    
    @IBOutlet weak var locationSubView: UIView!
    
    @IBOutlet weak var serviceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reserveButton: UIButton!
    
    var dateSelected = Date()
    var yoberId = " "
    
    var timeArray = [String]()
    
    var serviceArray = [PFObject]()
    var serviceSelected = PFObject(className: "Service")
    
    var locationDataArray = [Data]()
    var locationStructArray = [userAddress]()
    var locationStringArray = [String]()
    
    let tableList = UITableView()
    var selectedButton = UIButton()
    var dateComplete = Date()
    var buttonSelected = ""
    var service = ""
    var time = ""
    var location = ""
    
    let transparentView = UIView()
    
    var nameVoluntary = ""
    var serviceObjectId = ""
    
    //Time uniqueVar
    
    var datesComplete = [Date]()
    var places = 0
    var available = true
    
    override func viewDidLoad() {
        
        if self.nameVoluntary != "" {
            self.serviceLabel.text = self.nameVoluntary
            self.serviceButton.isUserInteractionEnabled = false
            self.getVoluntary()
        }else{
            self.serviceButton.isUserInteractionEnabled = true
        }
        
        super.viewDidLoad()
        
        self.updateView()
        
        serviceButton.roundCustomButton(divider: 16)
        serviceSubView.roundCustomView(divider: 16)

        timeButton.roundCustomButton(divider: 16)
        timeSubView.roundCustomView(divider: 16)
        
        locationButton.roundCustomButton(divider: 16)
        locationSubView.roundCustomView(divider: 16)
        
        yoberPhoto.roundCompleteImageColor()
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        self.dismissWithSwipe()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
    }
    
    func getVoluntary() {
        
        let querySearchRegistryUser = PFQuery(className: "Service")
        querySearchRegistryUser.whereKey("objectId", equalTo: self.serviceObjectId)
        querySearchRegistryUser.findObjectsInBackground { (objects, error) in
            
            if error == nil, let objects = objects {
                for object in objects {
                    self.serviceSelected = object
                    self.service = self.nameVoluntary
                }
            }
        }
    }
    
    func checkPass() {
        
        if(self.location != "" && self.service != "" && self.time != ""){
        
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "exploreGeneralInscription") as? exploreGeneralInscription

            viewController?.selection = "Service"
            viewController?.location = self.location
            viewController?.time = self.time
            viewController?.service = self.serviceSelected
            viewController?.dateSelected = self.dateSelected
        
            self.navigationController?.pushViewController(viewController!, animated: true)
        
        }else{
        
            let alert = UIAlertController(title: "ERROR", message: "Alguno de los campos no ha sido completado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        }
    
    }
    
    func searchAvaiblePlace() {

        let currentUser = PFUser.current()

        print("serviceObjectId: \(self.serviceObjectId)")

        let newTime = time.replacingOccurrences(of: ":00", with: "")
        var timeDate = 0
        if let actualTime = Int(newTime) {
            timeDate = actualTime
        }
        let date = Calendar.current.date(bySettingHour: timeDate, minute: 0, second: 0, of: dateSelected)!
        self.dateComplete = date

        let querySearchAvaiblePlace = PFQuery(className: "Reservation")
        querySearchAvaiblePlace.whereKey("activityId", contains: self.serviceObjectId)
        querySearchAvaiblePlace.whereKey("date", equalTo: self.dateComplete)
        querySearchAvaiblePlace.findObjectsInBackground { (objects, error) in

            if error == nil, let objects = objects {

                if objects.count == 0 {
                    print("aun nadie se registra en ese dia y en ese horaio")
                    self.checkPass()
                }else{
                    if objects.count < self.places{
                        print("hay lugares")
                        
                        let dispatchGroup = DispatchGroup()

                        for object in objects {
                            dispatchGroup.enter()
                            let user = object["user"] as? PFObject
                            let dateUser = object["date"] as? Date
                            
                            if user?.objectId == currentUser?.objectId && dateUser == self.dateComplete{
                                let alert = UIAlertController(title: "¡Alerta!", message: "Ya te registraste en esta fecha y en este horario", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        dispatchGroup.notify(queue: .main) {
                            self.checkPass()
                        }
                        
//                        for object in objects {
//                            let user = object["user"] as? PFObject
//                            let dateUser = object["date"] as? Date
//                            print("user: \(user?.objectId)")
//                            print("currentUser: \(currentUser?.objectId)")
//
//                            print("dateUser: \(dateUser)")
//                            print("currentDate: \(self.dateComplete)")
//
//                            if user?.objectId == currentUser?.objectId && dateUser == self.dateComplete{
//
//                                let alert = UIAlertController(title: "¡Alerta!", message: "Ya te registraste en esta fecha y en este horario", preferredStyle: .alert)
//                                    alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
//
//                                self.present(alert, animated: true, completion: nil)
//                            }else{
//                                self.checkPass()
//                            }
//                        }
                        
                    }else{
                        
                        print("no hay lugares")
                        let alert = UIAlertController(title: "¡Alerta!", message: "No hay lugares disponibles en este horario", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                            
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }else{
                print("error")
            }
        }
    }
    
    // MARK: BUTTOM FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func displayServiceList(_ sender: Any) {
        
        buttonSelected = "service"
        selectedButton = serviceButton
        
        fillTable(frames: serviceButton.frame, number: serviceArray.count, type: buttonSelected)
    }
    
    @IBAction func displayTimeList(_ sender: Any) {
        
        buttonSelected = "time"
        selectedButton = timeButton
        
        fillTable(frames: timeButton.frame, number: timeArray.count, type: buttonSelected)
    }
    
    @IBAction func displayLocationList(_ sender: Any) {
        
        buttonSelected = "location"
        selectedButton = locationButton
        
        if (locationStringArray.count > 0){
        
            fillTable(frames: locationButton.frame, number: locationStringArray.count, type: buttonSelected)
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "No ha registrado una dirección, ingrese a su perfil para hacerlo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func goToReserve(_ sender: Any) {
        
        self.searchAvaiblePlace()
        
//        if(location != "" && service != "" && time != ""){
//
//            let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreGeneralInscription") as? exploreGeneralInscription
//
//            viewController?.selection = "Service"
//            viewController?.location = location
//            viewController?.time = time
//            viewController?.service = serviceSelected
//            viewController?.dateSelected = dateSelected
//
//            self.navigationController?.pushViewController(viewController!, animated: true)
//
//        }else{
//
//            let alert = UIAlertController(title: "ERROR", message: "Alguno de los campos no ha sido completado", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
//            present(alert, animated: true, completion: nil)
//
//        }
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        self.getUser(keyFromAgenda: yoberId)
        self.getDate()
        self.getLocations()
        
    }
    
    //MARK: GET DATE
    
    func getDate(){
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "EEEE dd, MMMM yyyy"
        
        let labelDate = dateFormatter.string(from: dateSelected)
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        selectedDateLabel.text = labelDate
        
    }
    
    //MARK: GET USER
    
    func getUser(keyFromAgenda: String){
    
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:keyFromAgenda)
        
        queryYober.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
        if let error = error {
            // Log details of the failure
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
                    self.yoberName.text = newName
                }else{
                    self.yoberName.text = nil
                }
            
                self.getServices(object: object)
            
                self.yoberGrade.gradeResults(id: keyFromAgenda)
            
                if let newTimes = object["availableTimes"] as? [String]{
                    
                    if(newTimes.count > 0){
                    
                        if let newFrequency = object["timeFrequencyBlock"] as? String{
                        
                            self.timeArray = newTimes
                            
                            self.getReservationsOnTheSameDay(yober: object, timesOfYober: self.timeArray, timeFrequencyOfYober: newFrequency)
                        }
                    }
                }
            }
        }
    }
    
    func fillAddress(position: Int) -> String{
    
        let result = locationStructArray[position].street + ", " + locationStructArray[position].number + ", " + locationStructArray[position].reference + ", " + locationStructArray[position].colony + ", " + locationStructArray[position].city + ", " + locationStructArray[position].state
        
        return result
        
    }
    
    // MARK: TIME FUNCTION
    
    func getReservationsOnTheSameDay(yober: PFObject, timesOfYober: [String], timeFrequencyOfYober: String){
        
        //self.searchAvaiblePlace()
        
        self.datesComplete = self.editDateTime(arrayOfTimes: timesOfYober)

        let queryReservations = PFQuery(className: "Reservation")
           
        queryReservations.order(byAscending: "date")
        queryReservations.whereKey("date", containedIn: self.datesComplete)
        queryReservations.whereKey("yober", equalTo: yober)
        queryReservations.whereKey("type", equalTo: "Service")
                    
        queryReservations.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                        
            if let error = error {
                // Log details of the failure
                
                print(error.localizedDescription)
                
            } else if let objects = objects {
                // The find succeeded.
                
                var newArrayOfDatesR = [Date]()
                var newArrayDuration = [String]()
                
                if(objects.count > 0){
                    
                    for object in objects{
                        if let newDate = object["date"] as? Date{
                            print("newDate: \(newDate)")
                            newArrayOfDatesR.append(newDate)
                        }
                        
                        if let newDuration = object["duration"] as? String{
                            newArrayDuration.append(newDuration)
                        }
                    }
                    
                    self.timeArray = self.checkAvailability(arrayOfTimes: timesOfYober, arrayOfDatesUsed: newArrayOfDatesR, timesDuration: newArrayDuration, timeBetween: timeFrequencyOfYober)
                    
                    if(self.timeArray.count == 0){
                        let alert = UIAlertController(title: "ERROR", message: "El día seleccionado ya no tiene horarios disponibles", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Cerrar", style: .default){ (_) in
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func editDateTime( arrayOfTimes: [String] ) -> [Date]{
        
        var newDates = [Date]()
        
        for singleTime in arrayOfTimes{
            
            //MAKING THE TIME
            let newTime = singleTime.replacingOccurrences(of: ":00", with: "")
            var timeDate = 0
            
            if let actualTime = Int(newTime) {
                
                timeDate = actualTime
                
            }
            
            let date = Calendar.current.date(bySettingHour: timeDate, minute: 0, second: 0, of: dateSelected)!
            
            newDates.append(date)
            
        }
        
        return newDates
        
    }
    
    func checkAvailability( arrayOfTimes: [String], arrayOfDatesUsed: [Date], timesDuration: [String], timeBetween: String ) -> [String]{
        
        var newTimeArrayI = [Int]()
        var newDurationArrayI = [Int]()
        var newArrayDateTimeI = [Int]()
        var newTimeArrayS = [String]()
        
        //Convert all the arrayOfTimes to Ints
        for singleTime in arrayOfTimes{
            //MAKING THE TIME
            let newTime = singleTime.replacingOccurrences(of: ":00", with: "")
            var timeDate = 0
            if let actualTime = Int(newTime) {
                timeDate = actualTime
            }
            newTimeArrayI.append(timeDate)
        }
        
        //Convert all the arrayOfDurations to Ints
        for singleDuration in timesDuration{
            //MAKING THE TIME
            var timeDuration = 0
            let newDuration = singleDuration.replacingOccurrences(of: "horas", with: "")
            let newDuration2 = newDuration.replacingOccurrences(of: " ", with: "")
            if let actualDuration = Double(newDuration2) {
                timeDuration = Int(actualDuration)
            }
            newDurationArrayI.append(timeDuration)
        }
        
        //Convert all the arrayOfDateTime to Ints
        for singleDateTime in arrayOfDatesUsed{
            //MAKING THE TIME
            let dateFormatter = DateFormatter()
            //Convert to string and int
            dateFormatter.dateFormat = "HH"
            let hoursDate = dateFormatter.string(from: singleDateTime)
            let hour = Int(hoursDate)
            newArrayDateTimeI.append(hour!)
        }
        
        //Convert the timeBetween into a Int
        
        var timeBetweenI = 0
        let newDuration = timeBetween.replacingOccurrences(of: "horas", with: "")
        let newDuration2 = newDuration.replacingOccurrences(of: " ", with: "")
        if let actualDuration = Double(newDuration2) {
            timeBetweenI = Int(actualDuration)
        }
        
        let size = newArrayDateTimeI.count
        for time in newTimeArrayI{
            var x = 0
            while (x < size){
                
                //Modifique los >= si reservo a las 12, me deberian apareces disponible a las 10 y a las 14
                
                if  ((time > newArrayDateTimeI[x] && time < newArrayDateTimeI[x]+newDurationArrayI[x]+timeBetweenI) || ( time > newArrayDateTimeI[x]-newDurationArrayI[x]-timeBetweenI && time < newArrayDateTimeI[x]) ){
                    
                    break
                }else {
                    x = x + 1
                    if(x == size){
                        var newStringTime = ""
                        if(time < 10){
                            newStringTime = "0"+String(time)+":00"
                            newTimeArrayS.append(newStringTime)
                            break
                        }
                        newStringTime = String(time)+":00"
                        newTimeArrayS.append(newStringTime)
                        break
                    }
                }
            }
        }
        return newTimeArrayS
    }
    
    // MARK: TABLE FUNCTIONS
    
    func getServices(object: PFObject){
        
        let queryService = PFQuery(className: "Service")
        
        queryService.whereKey("yober", equalTo: object)
        queryService.whereKey("active", equalTo: true)
        queryService.whereKey("private", equalTo: false)
        queryService.includeKey("yober")
        
        queryService.findObjectsInBackground { (objects: [PFObject]!, error: Error?) in
        
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                self.serviceArray = objects
            
            }
        
        }
        
    }
    
    func getLocations(){
        
        let user = PFUser.current()!
        
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
        
    }
    
    func fillTable(frames: CGRect, number: Int, type: String){
        
        if( self.scrollView.frame.height > CGFloat(600) ){
            
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
        
        tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        
        self.contentView.addSubview(tableList)
        
        tableList.layer.cornerRadius = 0.5
        
        tableList.reloadData()
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0.02
            
            if ( number >= 5){
                    
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 200)
                    
            }else{
                    
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(number * 40))
                    
            }
            
            /*
             
                CASE => SERVICE : 20 - UpperContrain - 20 Bottom Contrain - 40 HEIGHT = LOCATION IN UPPER VIEW -> 258
                
                CASE => TIME : 25 - UpperContrain - 20 Bottom Contrain - 40 HEIGHT = LOCATION IN UPPER VIEW -> 318
             
                CASE => DIRECTIONS : 20 - UpperContrain - Contrain - 40 HEIGHT = LOCATION IN UPPER VIEW -> 378
             
                CONTENT VIEW DEFAULT HEIGHT = 600
             
            */
            
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

// MARK: EXTENSION TABLEVIEW

extension exploreServiceRegisterDetails: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "service"){
            
            return serviceArray.count
            
        }else if(buttonSelected == "time"){
            
            return timeArray.count
            
        }else if(buttonSelected == "location"){
            
            return locationStringArray.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "service"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            if let newNameService = serviceArray[indexPath.row]["name"] as? String{
                
                cell.textLabel?.text = newNameService
                cell.textLabel?.font = serviceLabel.font
                
            }
            
            serviceSelected = serviceArray[indexPath.row]
            
            return cell
            
        }else if(buttonSelected == "time"){
                
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
                
            cell.textLabel?.text = timeArray[indexPath.row]
            cell.textLabel?.font = timeLabel.font
                
            return cell
            
        }else if(buttonSelected == "location"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = locationStringArray[indexPath.row]
            cell.textLabel?.font = locationLabel.font
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "service"){
            
            if let newNameServices : String = serviceArray[indexPath.item]["name"] as? String{
                
                serviceLabel.text = newNameServices
                service = newNameServices
                removeTableView()
            
            }else{
                
                print("It didnt work")
                
            }
            
        }else if(buttonSelected == "time"){
         
            time = timeArray[indexPath.row]
            timeLabel.text = time
            removeTableView()
            
        }else if(buttonSelected == "location"){
            
            location = locationStringArray[indexPath.row]
            locationLabel.text = location
            removeTableView()
            
        }else{
            
            removeTableView()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
