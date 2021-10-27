//
//  createPrivateService.swift
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

protocol goToPageEdit {
    func buttonTapFirst()
}

class createPrivateService: UIViewController{
    
    //MARK: OUTLET
    
    @IBOutlet weak var serviceName: UITextField!
    @IBOutlet weak var viewChangerButton: UISegmentedControl!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categorySubView: UIView!
    @IBOutlet weak var durationLabel: UITextField!
    @IBOutlet weak var susButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tempCost: UITextField!
    @IBOutlet weak var trueCost: UITextField!
    @IBOutlet weak var dateSelected: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var timeSubView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: VARs/LETs
    
    var serviceCreated = false
    var service = PFObject(className: "Service")
    var delegate : goToPageEdit?
    
    //TABLE LIST GENERAL
    
    let tableList = UITableView()
    var selectedButton = UIButton()
    var buttonSelected = ""
    let transparentView = UIView()
    
    //CATEGORIES LIST
    
    var categoryName = [String]()
    
    //DATE PICKER
    
    let datePickerView = UIDatePicker()
    var timeArray = [String]()
    var selectedDate = Date()
    var timeSelected = ""
    
    //Time uniqueVar
    
    var datesComplete = [Date]()
    
    //EXTRA DETAILS
    
    var normalCost = 0.0
    var percent = 0.0
    var minimumCost = 0.0
    var timeValue = 0.0
    
    
    
    //CLASS TO CALL
    
    weak var messagePrivatePrevious : messagePrivate?
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        self.createDatePicker()
        
        self.queryGeneral()
        
        self.queryForCategory()
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        serviceName.createBottomLineAlt()
        trueCost.createBottomLineAlt()
        dateSelected.createBottomLineAlt()
        
        timeSubView.roundCustomView(divider: 16)
        categorySubView.roundCustomView(divider: 16)
        
        addButton.roundCompleteButton()
        susButton.roundCompleteButton()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(true)
        viewChangerButton.selectedSegmentIndex = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
            
            self.sendAlert()
            
        }
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func changeView(_ sender: UISegmentedControl) {
        
        print("Touched")
        
        if viewChangerButton.selectedSegmentIndex == 0 {
            
            print("Enter")
            
            delegate?.buttonTapFirst()
            
        }
        
    }
    
    
    @IBAction func callTimeList(_ sender: UIButton) {
        
        buttonSelected = "time"
        selectedButton = timeButton
        
        fillTable(frames: timeButton.frame, number: timeArray.count)
        
    }
    
    @IBAction func callTypeList(_ sender: UIButton) {
        
        buttonSelected = "category"
        selectedButton = categoryButton
        
        fillTable(frames: categoryButton.frame, number: categoryName.count)
        
        
    }
    
    
    @IBAction func textChange(_ sender: UITextField) {
        
        if(tempCost.text != nil && tempCost.text != ""){
            
            let rawCost = Double(tempCost.text!)!
            
            let fullCost = rawCost * percent
            
            trueCost.text = String(format: "%.2f", fullCost)
            
        }else{
            
            trueCost.text = "0.0"
            
        }
        
    }
    
    @IBAction func saveService(_ sender: UIButton) {
        
        if( checkAllData() == false ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "Uno de los campos no ha sido completado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else if( Double( tempCost.text! )! < minimumCost ){
            
            let alert = UIAlertController(title: "ERROR", message: "El precio del servicio es menor al mínimo de $\(minimumCost).MX", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            let logo = UIImage(named: "imageBackground")
            let imageData = logo?.jpegData(compressionQuality: 1.0)
            let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
            service["logo"] = imageFile
            service["name"] = serviceName.text
            service["description"] = ""
            service["duration"] = durationLabel.text
            service["category_name"] = categoryLabel.text
            service["price"] = "$"+trueCost.text!+" MXN"
            service["places"] = 1
            service["view"] = 0
            service["inscriptions"] = 0
            service["active"] = true
            service["private"] = true
            
            //TIME CONVERTION
            
            let newTime = timeSelected.replacingOccurrences(of: ":00", with: "")
            var timeDate = 0
            
            if let actualTime = Int(newTime) {
                
                timeDate = actualTime
                
            }
            
            let date = Calendar.current.date(bySettingHour: timeDate, minute: 0, second: 0, of: datePickerView.date)!
            
            selectedDate = date
            
            service["date"] = selectedDate
            
            //AFTER TIME CONVERTION
            
            guard let user = PFUser.current() else{
                
                self.sendAlert()
                
                return
                
            }
                
            service["yober"] = user
            
            guard let messagePP = messagePrivatePrevious else{
                
                print("It seems is a nil")
                
                return
                
            }
            
            serviceCreated = true
            
            print(messagePP)
            
            if( serviceCreated == true ){
                
               messagePP.sendService(sendService: service)
            
                _ = navigationController?.popViewController(animated: true)
                
            }
            
        }
        
    }
    
    @IBAction func addTime(_ sender: UIButton) {
        
        if(timeValue < 8){
            
            timeValue = timeValue + 0.5
            durationLabel.text = String(timeValue) + " horas"
            
        }
        
    }
    
    @IBAction func susTime(_ sender: UIButton) {
        
        if(timeValue > 0){
            
            timeValue = timeValue - 0.5
            durationLabel.text = String(timeValue) + " horas"
            
        }
        
    }
    
    
    
    //MARK: QUERY FUNCTIONS
    
    func queryForCategory(){
        
        let query = PFQuery(className: "Category")
        
        query.findObjectsInBackground { (objects, error) in
            
            if let error = error{
                print(error.localizedDescription)
            }else{
                
                if let objects = objects{
                    
                    for type in objects{
                        
                        self.categoryName.append(type["name"] as! String)
                        
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
        
        if( serviceName.text == nil || serviceName.text == "" || durationLabel.text == nil || durationLabel.text == "0.0" || categoryLabel.text == "" || categoryLabel.text == nil || tempCost.text == nil || tempCost.text == "" || trueCost.text == nil || trueCost.text == "" || dateSelected.text == nil || trueCost.text == "" || timeLabel.text == nil || timeLabel.text == "" ){
            
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

extension createPrivateService: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "category"){
            
            return categoryName.count
            
        }else if(buttonSelected == "time"){
            
            return timeArray.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "category"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = categoryName[indexPath.row]
            cell.textLabel?.font = serviceName.font
            
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
        
        if(buttonSelected == "category"){
            
            categoryLabel.text = categoryName[indexPath.row]
            removeTableView()
            
            
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

extension createPrivateService{
    
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
