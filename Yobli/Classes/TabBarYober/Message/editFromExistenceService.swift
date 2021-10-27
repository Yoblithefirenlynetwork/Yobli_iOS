//
//  editFromExistenceService.swift
//  Yobli
//
//  Created by Brounie on 09/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import IQKeyboardManagerSwift
import MBProgressHUD
import Firebase
import MessageKit

protocol goToPageCreate {
    func buttonTapSecond()
}

class editFromExistenceService: UIViewController{
    
    //MARK: OUTLET
    
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var viewChangerButton: UISegmentedControl!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var serviceSubView: UIView!
    @IBOutlet weak var extraDetails: UITextField!
    @IBOutlet weak var extraCost: UITextField!
    @IBOutlet weak var trueCost: UITextField!
    @IBOutlet weak var dateSelected: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var timeSubView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: VARs/LETs
    
    var serviceCreated = false
    var service = PFObject(className: "Service")
    var newService = PFObject(className: "Service")
    var delegate : goToPageCreate?
    
    //TABLE LIST GENERAL
    
    let tableList = UITableView()
    var selectedButton = UIButton()
    var buttonSelected = ""
    let transparentView = UIView()
    
    //SERVICE LIST
    
    var servicesNames = [String]()
    var services = [PFObject]()
    
    //DATE PICKER
    
    let datePickerView = UIDatePicker()
    var timeArray = [String]()
    var timeSelected = ""
    var selectedDate = Date()
    
    //Time uniqueVar
    
    var datesComplete = [Date]()
    
    //EXTRA DETAILS
    
    var normalCost = 0.0
    var minimumCost = 0.0
    var percent = 0.0
    
    //CLASS TO CALL
    
    weak var messagePrivatePrevious : messagePrivate?
    
    //MARK: MAIN FUNCTION
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        self.createDatePicker()
        
        self.queryGeneral()
        
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            
            return
            
        }
        
        self.queryForServices(creator: user)
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        extraDetails.createBottomLineAlt()
        extraCost.createBottomLineAlt()
        trueCost.createBottomLineAlt()
        dateSelected.createBottomLineAlt()
        serviceSubView.roundCustomView(divider: 16)
        timeSubView.roundCustomView(divider: 16)
        
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        viewChangerButton.selectedSegmentIndex = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil || Auth.auth().currentUser == nil{
            
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        serviceCreated = false
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func changeView(_ sender: UISegmentedControl) {
        
        print("Press")
        
        if viewChangerButton.selectedSegmentIndex == 1 {
            
            print("Enter")
            
            delegate?.buttonTapSecond()
            
        }
        
    }
    
    @IBAction func callServiceList(_ sender: Any) {
        
        buttonSelected = "service"
        selectedButton = serviceButton
        
        fillTable(frames: serviceButton.frame, number: services.count)
        
    }
    
    @IBAction func callTimeList(_ sender: UIButton) {
        
        buttonSelected = "time"
        selectedButton = timeButton
        
        fillTable(frames: timeButton.frame, number: timeArray.count)
        
    }
    
    @IBAction func textChange(_ sender: UITextField) {
        
        if(extraCost.text != nil && extraCost.text != ""){
            
            let rawCost = Double(extraCost.text!)!
            
            let fullCost = ( rawCost + normalCost ) * percent
            
            trueCost.text = String(format: "%.2f", fullCost)
            
        }
        
    }
    
    @IBAction func saveService(_ sender: UIButton) {
        
        if( checkAllData() == false ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "Uno de los campos no ha sido completado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            newService["logo"] = service["logo"]
            newService["name"] = serviceName.text! + " (personalizado)"
            
            guard let originalDescription = service["description"] as? String else{
                return
            }
            
            newService["description"] = originalDescription + extraDetails.text!
            newService["duration"] = service["duration"]
            newService["category_name"] = service["category_name"]
            newService["price"] = "$"+trueCost.text!+" MXN"
            newService["places"] = service["places"]
            newService["view"] = 0
            newService["inscriptions"] = 0
            newService["active"] = true
            newService["private"] = true
            
            //MAKING THE TIME
            let newTime = timeSelected.replacingOccurrences(of: ":00", with: "")
            var timeDate = 0
            
            if let actualTime = Int(newTime) {
                
                timeDate = actualTime
                
            }
            
            let date = Calendar.current.date(bySettingHour: timeDate, minute: 0, second: 0, of: datePickerView.date)!
            
            selectedDate = date
            
            newService["date"] = selectedDate
            
            //AFTER TIME
            
            newService["yober"] = service["yober"]
            
            guard let messagePP = messagePrivatePrevious else{
                
                print("It seems is a nil")
                
                return
                
            }
            
            serviceCreated = true
            
            print(messagePP)
            
            if( serviceCreated == true ){
                
               messagePP.sendService(sendService: newService)
            
                _ = navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    //MARK: QUERY FUNCTIONS
    
    func queryForServices(creator: PFObject){
        
        let query = PFQuery(className: "Service")
        print("creator: \(creator)")
        query.whereKey("yober", equalTo: creator)
        query.whereKey("private", equalTo: false)
        query.includeKey("yober")
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error{
                print(error.localizedDescription)
            }else{
                
                if let objects = objects{
                    print("objects: \(objects)")
                    self.services = objects
                    
                    for service in self.services{
                        
                        self.servicesNames.append(service["name"] as! String)
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    func queryGeneral(){
        
        let query = PFQuery(className: "Global")
        
        query.getFirstObjectInBackground { (object, error) in
            
            if let error = error{
                self.sendErrorTypeAndDismiss(error: error)
            }else{
                
                if let object = object{
                    
                    guard let percentCost = object["percentCost"] as? Double, let minimumCost = object["minimumCost"] as? Double else{
                        
                        return
                        
                    }
                    
                    self.percent = percentCost
                    self.minimumCost = minimumCost
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: CHECK FUNCTIONS
    
    func checkAllData() -> Bool{
        
        if( serviceName.text == nil || serviceName.text == "" || trueCost.text == nil || trueCost.text == "" || dateSelected.text == nil || trueCost.text == "" || timeLabel.text == nil || timeLabel.text == "" ){
            
            return false
            
        }else{
            
            return true
            
        }
        
    }
    
    //MARK: DATE PICKER FUNCTIONS
    
    func createDatePicker(){
        
        self.datePickerView.locale = Locale(identifier: "es_MX")
        self.datePickerView.timeZone = NSTimeZone.local
        
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .month, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .minute, value: 0, to: Date())
        
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.dateSelected.inputView = datePickerView
        
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 50.0)))
        toolBar.sizeToFit()
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed) )
        toolBar.setItems([barButton], animated: true)
        
        dateSelected.inputAccessoryView = toolBar
        
    }
    
    @objc func donePressed(){
        
        self.showHUD(progressLabel: "Comprobando fecha...")
        
        timeLabel.text = nil
        
        dateSelected.text = self.dateFormat(date: datePickerView.date)
        
        guard let user = PFUser.current() else{
            
            self.dismissHUD(isAnimated: true)
            self.sendAlert()
            
            return
            
        }
        
        if let newTimes = user["availableTimes"] as? [String]{
            
            if(newTimes.count > 0){
            
                if let newFrequency = user["timeFrequencyBlock"] as? String{
                
                    self.timeArray = newTimes
                    
                    self.getReservationsOnTheSameDay(yober: user, timesOfYober: self.timeArray, timeFrequencyOfYober: newFrequency)
                    
                }
                
            }else{
                
                self.dismissHUD(isAnimated: true)
                
                let alert = UIAlertController(title: "ERROR", message: "El usuario no tiene tiempos disponibles en su agenda", preferredStyle: .alert)
                            
                let action = UIAlertAction(title: "Cerrar", style: .default){ (_) in
                    
                    self.dateSelected.text = nil
                    
                }
                
                alert.addAction(action)
                            
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        self.view.endEditing(true)
        
    }
    
    // MARK: TIME FUNCTION
    
    func getReservationsOnTheSameDay(yober: PFObject, timesOfYober: [String], timeFrequencyOfYober: String){
        
        self.datesComplete = self.editDateTime(arrayOfTimes: timesOfYober)
                    
        let queryReservations = PFQuery(className: "Reservation")
                    
        queryReservations.whereKey("date", containedIn: self.datesComplete)
        queryReservations.whereKey("yober", equalTo: yober)
        queryReservations.whereKey("type", equalTo: "Service")
                    
        queryReservations.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                        
            if let error = error {
                // Log details of the failure
                self.dismissHUD(isAnimated: true)
                self.sendErrorType(error: error)
            } else if let objects = objects {
                // The find succeeded.
                
                var newArrayOfDatesR = [Date]()
                var newArrayDuration = [String]()
                
                if(objects.count > 0){
                
                    for object in objects{
                        
                        if let newDate = object["date"] as? Date{
                            
                            newArrayOfDatesR.append(newDate)
                            
                        }
                        
                        if let newDuration = object["duration"] as? String{
                            
                            newArrayDuration.append(newDuration)
                            
                        }
                        
                    }
                    
                    self.timeArray = self.checkAvailability(arrayOfTimes: timesOfYober, arrayOfDatesUsed: newArrayOfDatesR, timesDuration: newArrayDuration, timeBetween: timeFrequencyOfYober)
                    
                    if(self.timeArray.count == 0){
                        
                        self.dismissHUD(isAnimated: true)
                        
                        let alert = UIAlertController(title: "ERROR", message: "El día seleccionado ya no tiene horarios disponibles", preferredStyle: .alert)
                                    
                        let action = UIAlertAction(title: "Cerrar", style: .default){ (_) in
                            
                            self.dateSelected.text = nil
                            
                        }
                        
                        alert.addAction(action)
                                    
                        self.present(alert, animated: true, completion: nil)
                        
                    }else{
                        
                        self.dismissHUD(isAnimated: true)
                        
                    }
                    
                }else{
                    
                    self.dismissHUD(isAnimated: true)
                    
                }
                            
                        
            }
                        
        }
        
    }
    
    //MARK: TIME EDIT FUNCTIONS
    
    func editDateTime( arrayOfTimes: [String] ) -> [Date]{
        
        var newDates = [Date]()
        
        for singleTime in arrayOfTimes{
            
            //MAKING THE TIME
            let newTime = singleTime.replacingOccurrences(of: ":00", with: "")
            var timeDate = 0
            
            if let actualTime = Int(newTime) {
                
                timeDate = actualTime
                
            }
            
            let date = Calendar.current.date(bySettingHour: timeDate, minute: 0, second: 0, of: selectedDate)!
            
            newDates.append(date)
            
        }
        
        return newDates
        
    }
    
    func checkAvailability( arrayOfTimes: [String], arrayOfDatesUsed: [Date], timesDuration: [String], timeBetween: String ) -> [String]{
        
        var newTimeArrayI = [Int]()
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
        
        var newDurationArrayI = [Int]()
        
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
        
        var newArrayDateTimeI = [Int]()
        
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
            
                if ( ( time >= newArrayDateTimeI[x] && time <= newArrayDateTimeI[x]+newDurationArrayI[x]+timeBetweenI ) || ( time >= newArrayDateTimeI[x]-newDurationArrayI[x]-timeBetweenI && time <= newArrayDateTimeI[x] ) ){
                    
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
    //MARK: TABLE FUNCTIONS
    
    func fillTable(frames: CGRect, number: Int){
        
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
    
    //MARK: CHANGE DATE FORMAT
    
    func dateFormat(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateStyle = .short
        
        let labelDate = dateFormatter.string(from: date)
        
        return labelDate
        
    }
    
}

//MARK: EXTENSION TABLEVIEW

extension editFromExistenceService: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "service"){
            
            return services.count
            
        }else if(buttonSelected == "time"){
            
            return timeArray.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "service"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            if let newNameService = services[indexPath.row]["name"] as? String{
                
                cell.textLabel?.text = newNameService
                cell.textLabel?.font = serviceName.font
                
            }
            
            return cell
            
        }else if(buttonSelected == "time"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
                
            cell.textLabel?.text = timeArray[indexPath.row]
            cell.textLabel?.font = timeLabel.font
                
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "service"){
            
            if let newNameServices : String = services[indexPath.row]["name"] as? String{
                
                serviceName.text = newNameServices
                
                if let newPrice = services[indexPath.row]["price"] as? String{
                    
                    let newPrice2 = newPrice.replacingOccurrences(of: "$", with: "")
                    let newPrice3 = newPrice2.replacingOccurrences(of: "MXN", with: "")
                    let newPrice4 = newPrice3.replacingOccurrences(of: " ", with: "")
                    
                    if let actualPrice = Double(newPrice4) {
                        
                        let userPrice1 = actualPrice/percent
                        
                        self.normalCost = userPrice1
                        
                        self.extraCost.isEnabled = true
                        self.extraCost.text = ""
                        self.trueCost.text = String(actualPrice)
                        
                    } else {
                        
                        print("Error")
                        
                    }
                    
                }
                
                service = services[indexPath.row]
                
                removeTableView()
            
            }else{
                
                print("It didnt work")
                
            }
            
        }else if(buttonSelected == "time"){
            
            timeLabel.text = timeArray[indexPath.row]
            timeSelected = timeArray[indexPath.row]
            
            removeTableView()
        
        }else{
            
            removeTableView()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

//MARK: EXTENSION MBPROGRESSHUD

extension editFromExistenceService{
    
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
