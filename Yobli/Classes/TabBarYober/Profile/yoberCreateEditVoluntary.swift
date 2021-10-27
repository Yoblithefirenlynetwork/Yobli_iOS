//
//  yoberCreateEditVoluntary.swift
//  Yobli
//
//  Created by Brounie on 05/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class yoberCreateEditVoluntary: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var titleUp: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var smallDescription: UITextField!
    @IBOutlet weak var fullDescription: UITextView!
    @IBOutlet weak var timeDate: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var addTimeButton: UIButton!
    @IBOutlet weak var susTimeButton: UIButton!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var causeLabel: UILabel!
    @IBOutlet weak var causeButton: UIButton!
    @IBOutlet weak var availablePlaces: UITextField!
    @IBOutlet weak var transportSelection: UISegmentedControl!
    @IBOutlet weak var alimentSelection: UISegmentedControl!
    @IBOutlet weak var specialRequirements: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: VARs/LETs
    
    var isNew = true
    var editableVoluntary = PFObject(className: "Voluntary")
    
    //TABLE LIST VALUES
    
    var voluntaryCausesArray = [PFObject]()
    var voluntaryStatesArray = [PFObject]()
    var cause : PFObject?
    var cityArray = [String]()
    var stateArray = [String]()
    var citySelected = ""
    var stateSelected = ""
    let tableList = UITableView()
    var selectedButton = UIButton()
    var buttonSelected = ""
    let transparentView = UIView()
    
    //DATE PICKER
    
    let datePickerView = UIDatePicker()
    var originalDate = Date()
    var currentDate = Date()
    
    //RESERVATIONS
    
    var reservationsDone = [PFObject]()
    
    //COMPARE IMAGE
    
    var imageCompare = UIImage(named: "imageBackground")
    
    //CHECK IF
    
    var transportInVoluntary = false
    var alimentInVoluntary = false
    
    var timeValue = 0.0

    //Schedule
    
    var scheduleArray = [Schedule]()
    var endSchedule = Date()
    
    //MARK: MAIN FUNCTION DIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.queries()
        self.queries2()
        
        print("scheduleArrayVoluntary: \(self.scheduleArray)")
        
        if(isNew == false){
            
            self.titleUp.text = ""
            self.logoButton.isHidden = true
            self.name.isUserInteractionEnabled = false
            self.smallDescription.isUserInteractionEnabled = false
            self.fullDescription.isUserInteractionEnabled = false
            self.timeDate.isUserInteractionEnabled = false
            self.addTimeButton.isUserInteractionEnabled = false
            self.susTimeButton.isUserInteractionEnabled = false
            self.location.isUserInteractionEnabled = false
            self.stateButton.isUserInteractionEnabled = false
            self.cityButton.isUserInteractionEnabled = false
            self.causeButton.isUserInteractionEnabled = false
            self.availablePlaces.isUserInteractionEnabled = false
            self.transportSelection.isUserInteractionEnabled = false
            self.alimentSelection.isUserInteractionEnabled = false
            self.specialRequirements.isUserInteractionEnabled = false
            self.saveButton.isHidden = true
            
            self.showHUD(progressLabel: "Cargando...")
            
            self.updateView()
            
        }
        
        self.createDatePicker()
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        logo.roundCompleteImageColor()
        logoButton.roundCompleteButtonColor()
        
        addTimeButton.roundCompleteButton()
        susTimeButton.roundCompleteButton()
        
        name.generalBottomLine()
        smallDescription.generalBottomLine()
        timeDate.generalBottomLine()
        location.generalBottomLine()
        availablePlaces.generalBottomLine()
        fullDescription.generalBottomLine()
        specialRequirements.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
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
    
    @IBAction func thereIsAliment(_ sender: Any) {
        
        if alimentSelection.selectedSegmentIndex == 0 {
            
            alimentInVoluntary = true
            
        }else if alimentSelection.selectedSegmentIndex == 1 {
            
            alimentInVoluntary = false
            
        }else{
            
            alimentInVoluntary = false
            
        }
        
    }
    
    @IBAction func thereIsTransport(_ sender: UISegmentedControl) {
        
        if transportSelection.selectedSegmentIndex == 0 {
            
            transportInVoluntary = true
            
        }else if transportSelection.selectedSegmentIndex == 1 {
            
            transportInVoluntary = false
            
        }else{
            
            transportInVoluntary = false
            
        }
        
    }
    
    
    @IBAction func getPhoto(_ sender: Any) {
        
        let selectOption = UIAlertController()
        let imagePicker = UIImagePickerController()
        
        selectOption.addAction(UIAlertAction(title: "Abrir Camara", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
                
            }else{
                
                let alert = UIAlertController(title: "ERROR", message: "No se ha dado acceso a la camara", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }))
        
        selectOption.addAction(UIAlertAction(title: "Abrir Galería", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
                
            }else{
                
                let alert = UIAlertController(title: "ERROR", message: "No se ha dado acceso a la galería", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        
        selectOption.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(selectOption, animated: true, completion: nil)
        
    }
    
    @IBAction func displayStatesList(_ sender: Any) {
        
        buttonSelected = "states"
        selectedButton = stateButton
        
        fillTable(frames: stateButton.frame, number: voluntaryStatesArray.count)
        
    }
    
    @IBAction func displayCityList(_ sender: Any){
        
        if(stateSelected != ""){
            
            buttonSelected = "cities"
            selectedButton = cityButton
            self.getCities(stateName: stateSelected)
            
            fillTable(frames: cityButton.frame, number: cityArray.count)
            
        }
        
    }
    
    @IBAction func displayCausesList(_ sender: Any) {
        
        buttonSelected = "causes"
        selectedButton = causeButton
        
        fillTable(frames: causeButton.frame, number: voluntaryCausesArray.count)
        
    }
    
    //MARK: BUTTON SAVE VOLUNTARY
    
    @IBAction func saveVoluntary(_ sender: Any) {
        
        self.endSchedule = self.datePickerView.date.addingTimeInterval(timeValue*60*60)
        
        if( checkAllData() == false ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "Los campos no han sido completados", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "ATENCIÓN", message: "No podrás editar el voluntariado una vez creado", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            let action = UIAlertAction(title: "Aceptar", style: .default){ (_) in
                
                if self.isNew == true {

                    self.checkTime(startNewSchedule: self.datePickerView.date, endNewSchedule: self.endSchedule)
                    //saveNew()
                    
                }else{
                    
                    //self.checkTime(startNewSchedule: self.datePickerView.date, endNewSchedule: self.endSchedule)
                    //saveOld()
                }
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addTime(_ sender: Any) {
        
        if(timeValue < 8){
            
            timeValue = timeValue + 0.5
            durationLabel.text = String(timeValue) + " horas"
            self.endSchedule = self.datePickerView.date.addingTimeInterval(timeValue*60*60)
            
        }
        
    }
    
    @IBAction func susTime(_ sender: Any) {
        
        if(timeValue > 0){
            
            timeValue = timeValue - 0.5
            durationLabel.text = String(timeValue) + " horas"
            self.endSchedule = self.datePickerView.date.addingTimeInterval(timeValue*60*60)
            
        }
        
    }
    
    func checkTime(startNewSchedule: Date, endNewSchedule: Date) {
        
        var scheduleBool = true
        
        for schedule in scheduleArray{
            
            if scheduleBool == true {
            
                if startNewSchedule < schedule.startSchedule && endNewSchedule <= schedule.startSchedule{
                    scheduleBool = true
                }else if startNewSchedule >= schedule.endSchedule && endNewSchedule > schedule.endSchedule {
                    scheduleBool = true
                }else{
                    scheduleBool = false
                }
            }else{
                print("se detuvo")
            }
        }
        
        if scheduleBool == true {
            print("puedes crear curso")
            if(self.isNew == true){
                saveNew()
            }else{
                //saveOld()
            }
        }else{
            let alert = UIAlertController(title: "¡Alerta!", message: "Existe un curso o voluntariado en ese horario", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func truncateSecondsForDate(fromDate: Date) -> Date {

        let calendar = Calendar.current
        let fromDateComponents: DateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: fromDate as Date) as DateComponents

        return calendar.date(from: fromDateComponents as DateComponents)! as Date
    }
    
    // MARK: SAVE NEW OBJECT
    
    func saveNew(){
        
        
        self.showHUD(progressLabel: "Guardando Información")
        
        print("date: \(self.datePickerView.date)")
        print("format: \(self.truncateSecondsForDate(fromDate:self.datePickerView.date))")
        
        
        let imageData = logo.image?.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
        editableVoluntary["logo"] = imageFile
        editableVoluntary["name"] = name.text
        editableVoluntary["smallDescription"] = smallDescription.text
        editableVoluntary["description"] = fullDescription.text
        editableVoluntary["date"] = self.truncateSecondsForDate(fromDate: self.datePickerView.date)
        editableVoluntary["endDate"] = self.truncateSecondsForDate(fromDate: self.endSchedule)
        editableVoluntary["duration"] = durationLabel.text
        editableVoluntary["location"] = location.text
        editableVoluntary["cause"] = self.cause
        editableVoluntary["state"] = stateSelected
        editableVoluntary["city"] = citySelected
        editableVoluntary["places"] = Int(availablePlaces.text!)
        editableVoluntary["transport"] = transportInVoluntary
        editableVoluntary["food"] = alimentInVoluntary
        editableVoluntary["specialRequirements"] = specialRequirements.text
            
        editableVoluntary["view"] = 0
        editableVoluntary["inscriptions"] = 0
        editableVoluntary["active"] = true
                
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            return
            
        }
        
        editableVoluntary["yober"] = user
            
        editableVoluntary.saveInBackground {  (success: Bool?, error: Error?) in
                
            if let error = error {
                    
                self.dismissHUD(isAnimated: true)
                    
                self.sendErrorType(error: error)
                
            }else if success != nil{
                    
                self.dismissHUD(isAnimated: true)
                        
                let alert = UIAlertController(title: "ÉXITO", message: "Voluntariado Guardado", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                        
                self.present(alert, animated: true, completion: nil)
                        
                self.logo.image = self.imageCompare
                self.name.text = ""
                self.smallDescription.text = ""
                self.fullDescription.text = ""
                self.timeDate.text = ""
                self.durationLabel.text = ""
                self.location.text = ""
                self.causeLabel.text = ""
                self.cause = nil
                self.stateLabel.text = ""
                self.availablePlaces.text = ""
                self.transportSelection.selectedSegmentIndex = 1
                self.alimentSelection.selectedSegmentIndex = 1
                self.specialRequirements.text = ""
                self.editableVoluntary = PFObject(className: "Voluntary")
                    
            }
            
        }
        
    }
    
    // MARK: SAVE OLD OBJECT
    
    func saveOld(){
        
        self.showHUD(progressLabel: "Guardando Información")
        
        editableVoluntary.fetchInBackground { (result, error) in
            
            if let error = error{
                
                self.dismissHUD(isAnimated: true)
                self.sendErrorType(error: error)
                
            }else if let result = result{
                
                self.editableVoluntary = result
                
                let imageData = self.logo.image?.jpegData(compressionQuality: 1.0)
                let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
                self.editableVoluntary["logo"] = imageFile
                self.editableVoluntary["name"] = self.name.text
                self.editableVoluntary["smallDescription"] = self.smallDescription.text
                self.editableVoluntary["description"] = self.fullDescription.text
                self.editableVoluntary["date"] = self.datePickerView.date
                self.editableVoluntary["duration"] = self.durationLabel.text
                self.editableVoluntary["location"] = self.location.text
                self.editableVoluntary["cause"] = self.cause
                self.editableVoluntary["state"] = self.stateSelected
                self.editableVoluntary["city"] = self.citySelected
                self.editableVoluntary["places"] = Int(self.availablePlaces.text!)
                self.editableVoluntary["transport"] = self.transportInVoluntary
                self.editableVoluntary["food"] = self.alimentInVoluntary
                self.editableVoluntary["specialRequirements"] = self.specialRequirements.text
                    
                if( self.originalDate < self.currentDate && self.originalDate != self.datePickerView.date){
                    
                    self.editableVoluntary["view"] = 0
                    self.editableVoluntary["inscriptions"] = 0
                    self.editableVoluntary["active"] = true
                    
                }else{
                    
                    guard let id = self.editableVoluntary.objectId else{
                        print("It shouldnt happen")
                        return
                    }
                    
                    supportView.updateReservation(newDate: self.datePickerView.date, originalDate: self.originalDate, activityId: id, activityType: "Voluntary")
                    
                    self.originalDate = self.datePickerView.date
                    
                }
                    
                self.editableVoluntary.saveInBackground {  (success: Bool?, error: Error?) in
                        
                    if let error = error {
                            
                        self.dismissHUD(isAnimated: true)
                            
                        self.sendErrorType(error: error)
                        
                    }else if success != nil{
                            
                        self.dismissHUD(isAnimated: true)
                                    
                        let alert = UIAlertController(title: "ÉXITO", message: "Cambios guardados", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                                    
                        self.present(alert, animated: true, completion: nil)
                            
                    }
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: UPDATE VIEW
    
    func updateView(){
        
        if let imageInformation = editableVoluntary["logo"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.logo.image = image
                }
                
            }
            
        }else{
            
            self.logo.image = nil
            
        }
        
        if let newName = editableVoluntary["name"] as? String{
            self.name.text = newName
        }else{
            self.name.text = nil
        }
        
        if let newSmallDescription = editableVoluntary["smallDescription"] as? String{
            self.smallDescription.text = newSmallDescription
        }else{
            self.smallDescription.text = nil
        }
        
        if let newDescription = editableVoluntary["description"] as? String{
            
            self.fullDescription.text = newDescription
            
        }else{
            
            self.fullDescription.text = nil
            
        }
        
        if let newDate = editableVoluntary["date"] as? Date{
            
            datePickerView.date = newDate
            originalDate = newDate
            
            timeDate.text = self.dateFormat(date: newDate)
            
        }else{
            
            self.timeDate.text = nil
            
        }
        
        if let newDuration = editableVoluntary["duration"] as? String{
            
            let newDuration2 = newDuration.replacingOccurrences(of: "horas", with: "")
            let newDuration3 = newDuration2.replacingOccurrences(of: " ", with: "")
            
            if let actualDuration = Double(newDuration3) {
                
                timeValue = actualDuration
                self.durationLabel.text = newDuration
                
            } else {
                
                print("Error")
                
            }
            
            
        }else{
            
            self.durationLabel.text = nil
            
        }
        
        if let newLocation = editableVoluntary["location"] as? String{
            
            self.location.text = newLocation
            
        }else{
            
            self.location.text = nil
            
        }
        
        if let causeObject = editableVoluntary["cause"] as? PFObject{
            
            self.cause = causeObject
            
            guard let causeName = causeObject["name"] as? String else{
                print("Impossible")
                return
            }
            
            self.causeLabel.text = causeName
            
        }
        
        if let newState = editableVoluntary["state"] as? String{
            
            self.stateLabel.text = newState
            self.stateSelected = newState
            
        }else{
            
            self.stateLabel.text = nil
            
        }
        
        if let newCity = editableVoluntary["city"] as? String{
            
            self.cityLabel.text = newCity
            self.citySelected = newCity
            
        }else{
            
            self.cityLabel.text = nil
            
        }
        
        if let newNumberPart = editableVoluntary["places"] as? Int{
            
            self.availablePlaces.text = String(newNumberPart)
            
        }else{
            
            self.availablePlaces.text = nil
            
        }
        
        if let newTransport = editableVoluntary["transport"] as? Bool{
            
            if(newTransport == true){
                
                self.transportSelection.selectedSegmentIndex = 0
                
            }else{
                
                self.transportSelection.selectedSegmentIndex = 1
                
            }
            
            
        }else{
            
            self.transportSelection.selectedSegmentIndex = 1
            
        }
        
        if let newFood = editableVoluntary["food"] as? Bool{
            
            if(newFood == true){
                
                self.alimentSelection.selectedSegmentIndex = 0
                
            }else{
                
                self.alimentSelection.selectedSegmentIndex = 1
                
            }
            
            
        }else{
            
            self.alimentSelection.selectedSegmentIndex = 1
            
        }
        
        if let newSpecialRequirements = editableVoluntary["specialRequirements"] as? String{
            
            self.specialRequirements.text = newSpecialRequirements
            
        }else{
            
            self.specialRequirements.text = nil
            
        }
        
        self.dismissHUD(isAnimated: true)
        
    }
    
    // MARK: CHECK IF SOMETHING IS EMPTY
    
    func checkAllData() -> Bool{
        
        if( logo.image == nil || (logo.image?.isEqual(imageCompare))! || name.text == nil || name.text == "" || smallDescription.text == nil || smallDescription.text == "" || fullDescription.text == nil || fullDescription.text ==  "" || timeDate.text == nil || timeDate.text == "" || durationLabel.text == nil || durationLabel.text == "" || location.text == "" || location.text == nil || stateLabel.text == "" || stateLabel.text == nil || cityLabel.text == "" || cityLabel.text == nil || causeLabel.text == "" || causeLabel.text == nil || availablePlaces.text == nil || availablePlaces.text == "" || specialRequirements.text == nil || specialRequirements.text == "" ){
            
            return false
            
        }else{
            
            return true
            
        }
        
    }
    
    //MARK: DATEPICKER
    
    func createDatePicker(){
        
        self.datePickerView.locale = Locale(identifier: "es_ES")
        self.datePickerView.timeZone = NSTimeZone.local
        
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .month, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .minute, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .second, value: 0, to: Date())
        
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.timeDate.inputView = datePickerView
        
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: 50.0)))
        toolBar.sizeToFit()
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed) )
        toolBar.setItems([barButton], animated: true)
        
        timeDate.inputAccessoryView = toolBar
        
    }
    
    @objc func donePressed(){
        
        self.timeDate.text = self.dateFormat(date: datePickerView.date)
        self.view.endEditing(true)
        
    }
    
    // MARK: TABLE FUNCTIONS
    
    func queries(){
        
        let queryCities = PFQuery(className: "State")
        
        queryCities.findObjectsInBackground{ (objects: [PFObject]!, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let objects = objects {
                // The find succeeded.
                self.voluntaryStatesArray = objects
                
                for object in objects{
                    
                    if let newState = object["name"] as? String{
                        
                        self.stateArray.append(newState)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func queries2(){
        
        let queryCities = PFQuery(className: "Cause")
        
        queryCities.findObjectsInBackground{ (objects: [PFObject]!, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.voluntaryCausesArray = object
            }
            
        }
        
    }
    
    func getCities(stateName: String){
        
        var x = 0
        
        for state in stateArray{
            
            if(state == stateName){
                
                if let arrayOfCities = voluntaryStatesArray[x]["cities"] as? [String]{
                    
                    cityArray = arrayOfCities
                    break
                    
                }
                
            }
            
            x = x + 1
            
        }
        
        
    }
    
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
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
            self.transparentView.alpha = 0.02
            
            if ( number >= 4){
                
                self.tableList.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 200)
                
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
    
    // MARK: IMAGEPICKER FUNCTIONS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        logo.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: CHANGE DATE FORMAT
    
    func dateFormat(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        
        let labelDate = dateFormatter.string(from: date)
        
        return labelDate
        
    }
    
}

// MARK: EXTENSION TABLEVIEW

extension yoberCreateEditVoluntary: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "causes"){
            
            return voluntaryCausesArray.count
            
        }else if(buttonSelected == "states"){
            
            return voluntaryStatesArray.count
            
        }else if(buttonSelected == "cities"){
            
            if(stateSelected != ""){
                
                return cityArray.count
                
            }
            
            return 0
            
        }else{
            
            return 0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "states"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = voluntaryStatesArray[indexPath.row]["name"] as? String
            cell.textLabel?.font = stateLabel.font
            
            return cell
            
        }else if(buttonSelected == "cities"){
            
            if(stateSelected != ""){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
                
                cell.textLabel?.text = cityArray[indexPath.row]
                cell.textLabel?.font = cityLabel.font
                
                return cell
                
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = voluntaryCausesArray[indexPath.row]["name"] as? String
            cell.textLabel?.font = causeLabel.font
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "causes"){
            
            if let newNameCauses : String = voluntaryCausesArray[indexPath.row]["name"] as? String{
                
                causeLabel.text = newNameCauses
                cause = voluntaryCausesArray[indexPath.row]
                removeTableView()
                
            }else{
                
                print("It didnt work")
                
            }
            
        }else if(buttonSelected == "states"){
            
            if let newNameState : String = voluntaryStatesArray[indexPath.row]["name"] as? String{
                
                stateLabel.text = newNameState
                stateSelected = newNameState
                cityLabel.text = nil
                self.getCities(stateName: newNameState)
                removeTableView()
                
            }else{
                
                print("It didnt work")
                
            }
            
        }else if(buttonSelected == "cities"){
            
            if(stateSelected != ""){
                
                cityLabel.text = cityArray[indexPath.row]
                citySelected = cityArray[indexPath.row]
                removeTableView()
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension yoberCreateEditVoluntary{
    
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
