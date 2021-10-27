//
//  yoberCreateEditCourse.swift
//  Yobli
//
//  Created by Brounie on 05/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class yoberCreateEditCourse: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
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
    @IBOutlet weak var typeOfCourseLabel: UILabel!
    @IBOutlet weak var typeOfCourseButton: UIButton!
    @IBOutlet weak var typeOfCourseSubView: UIView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var availablePlaces: UITextField!
    @IBOutlet weak var costByUser: UITextField!
    @IBOutlet weak var actualCost: UITextField!
    @IBOutlet weak var specialRequirements: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var isNew = true
    
    //TABLE LIST VALUES
    
    var editableCourse = PFObject(className: "Course")
    var courseTypesArray = [PFObject]()
    var type : PFObject?
    let tableList = UITableView()
    var selectedButton = UIButton()
    let transparentView = UIView()
    var buttonSelected = ""
    
    //Schedule
    
    var scheduleArray = [Schedule]()
    var endSchedule = Date()
    
    //DATE PICKER
    
    let datePickerView = UIDatePicker()
    var originalDate = Date()
    var currentDate = Date()
    
    //RESERVATIONS
    
    var reservationsDone = [PFObject]()
    
    // IMAGE VIEW
    
    var imageCompare = UIImage(named: "imageBackground")
    
    //GENERAL VALUES
    
    var timeValue = 0.0
    var percent = 0.0
    var minimumCost = 0.0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.queries()
        self.getPercentageAndMinimunCost()
        
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
            self.typeOfCourseButton.isUserInteractionEnabled = false
            self.location.isUserInteractionEnabled = false
            self.availablePlaces.isUserInteractionEnabled = false
            self.costByUser.isUserInteractionEnabled = false
            self.actualCost.isUserInteractionEnabled = false
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
        
        typeOfCourseButton.roundCustomButton(divider: 32)
        typeOfCourseSubView.roundCustomView(divider: 32)
        
        name.generalBottomLine()
        smallDescription.generalBottomLine()
        timeDate.generalBottomLine()
        location.generalBottomLine()
        availablePlaces.generalBottomLine()
        costByUser.generalBottomLine()
        actualCost.generalBottomLine()
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
    
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
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
    
    
    @IBAction func saveCourse(_ sender: Any) {
        
        if self.checkAllData() == false {
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "Los campos no han sido completados", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else if( Double( costByUser.text! )! < minimumCost ){
            
            let alert = UIAlertController(title: "ERROR", message: "El precio del curso es menor al mínimo de $\(minimumCost).MX", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
            present(alert, animated: true, completion: nil)
                
        }else{
            let alert = UIAlertController(title: "ATENCIÓN", message: "No podrás editar el curso una vez creado", preferredStyle: .alert)
            
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
    
    @IBAction func displayTypesList(_ sender: Any) {
        
        buttonSelected = "type"
        selectedButton = typeOfCourseButton
        
        fillTable(frames: typeOfCourseButton.frame, number: courseTypesArray.count)
        
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        
        if(costByUser.text != nil && costByUser.text != ""){
            
            let rawCost = Double(costByUser.text!)!
            let fullCost = rawCost * percent
            
            actualCost.text = String(format: "%.2f", fullCost)
            
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
    
    //MARK: SAVE OLD COURSE
    
    func saveOld(){
        
        self.showHUD(progressLabel: "Guardando Información")
        
        editableCourse.fetchInBackground { (result, error) in
            
            if let error = error{
                
                self.dismissHUD(isAnimated: true)
                self.sendErrorType(error: error)
                
            }else if let result = result{
                
                self.editableCourse = result
                
                let imageData = self.logo.image?.jpegData(compressionQuality: 1.0)
                let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
                self.editableCourse["logo"] = imageFile
                self.editableCourse["name"] = self.name.text
                self.editableCourse["smallDescription"] = self.smallDescription.text
                self.editableCourse["description"] = self.fullDescription.text
                self.editableCourse["date"] = self.datePickerView.date
                self.editableCourse["duration"] = self.durationLabel.text
                self.editableCourse["endDate"] = self.endSchedule
                self.editableCourse["type"] = self.type
                self.editableCourse["location"] = self.location.text
                self.editableCourse["places"] = Int(self.availablePlaces.text!)
                self.editableCourse["price"] = "$"+self.actualCost.text!+" MXN"
                self.editableCourse["specialRequirements"] = self.specialRequirements.text
                        
                if( self.originalDate < self.currentDate && self.originalDate != self.datePickerView.date){
                    
                    self.editableCourse["view"] = 0
                    self.editableCourse["inscriptions"] = 0
                    self.editableCourse["active"] = true
                    
                }else{
                    
                    guard let id = self.editableCourse.objectId else{
                        print("It shouldnt happen")
                        return
                    }
                    //checar .. nos dice si ya hay alguien
                    supportView.updateReservation(newDate: self.datePickerView.date, originalDate: self.originalDate, activityId: id, activityType: "Course")
                    
                    self.originalDate = self.datePickerView.date
                    
                }
                
                self.editableCourse.saveInBackground {  (success: Bool?, error: Error?) in
                        
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
    
    func truncateSecondsForDate(fromDate: Date) -> Date {

        let calendar = Calendar.current
        let fromDateComponents: DateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: fromDate as Date) as DateComponents

        return calendar.date(from: fromDateComponents as DateComponents)! as Date
    }

    //MARK: SAVE NEW COURSE
    
    func saveNew(){
        
        self.showHUD(progressLabel: "Guardando Información")
        
        let imageData = logo.image?.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
        editableCourse["logo"] = imageFile
        editableCourse["name"] = name.text
        editableCourse["smallDescription"] = smallDescription.text
        editableCourse["description"] = fullDescription.text
        editableCourse["date"] = self.truncateSecondsForDate(fromDate: self.datePickerView.date)
        editableCourse["duration"] = durationLabel.text
        editableCourse["endDate"] = self.truncateSecondsForDate(fromDate: self.endSchedule)
        editableCourse["type"] = self.type
        editableCourse["location"] = location.text
        editableCourse["places"] = Int(availablePlaces.text!)
        editableCourse["price"] = "$"+actualCost.text!+" MXN"
        editableCourse["specialRequirements"] = specialRequirements.text
        
        editableCourse["view"] = 0
        editableCourse["inscriptions"] = 0
        editableCourse["active"] = true
                
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            return
            
        }
        
        editableCourse["yober"] = user
            
        editableCourse.saveInBackground {  (success: Bool?, error: Error?) in
                
            if let error = error {
                    
                self.dismissHUD(isAnimated: true)
                    
                self.sendErrorType(error: error)
                    
            }else if success != nil{
                    
                self.dismissHUD(isAnimated: true)
                        
                let alert = UIAlertController(title: "ÉXITO", message: "Curso Guardado", preferredStyle: .alert)
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
                self.typeOfCourseLabel.text = ""
                self.location.text = ""
                self.availablePlaces.text = ""
                self.costByUser.text = ""
                self.actualCost.text = ""
                self.specialRequirements.text = ""
                self.editableCourse = PFObject(className: "Course")
                self.type = nil
                    
            }
                
        }
        
    }
    
    // MARK: UPDATE FUNCTION
    
    func updateView(){
        
        if let imageInformation = editableCourse["logo"] as? PFFileObject{
        
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
        
        if let newName = editableCourse["name"] as? String{
            self.name.text = newName
        }else{
            self.name.text = nil
        }
        
        if let newSmallDescription = editableCourse["smallDescription"] as? String{
            self.smallDescription.text = newSmallDescription
        }else{
            self.smallDescription.text = nil
        }
        
        if let newDescription = editableCourse["description"] as? String{
            
            self.fullDescription.text = newDescription
            
        }else{
            
            self.fullDescription.text = nil
            
        }
        
        if let newDate = editableCourse["date"] as? Date{
            
            datePickerView.date = newDate
            originalDate = newDate
            
            timeDate.text = self.dateFormat(date: newDate)
            
        }else{
            
            self.timeDate.text = nil
            
        }
        
        if let newDuration = editableCourse["duration"] as? String{
            
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
        
        if let newLocation = editableCourse["location"] as? String{
            
            self.location.text = newLocation
            
        }else{
            
            self.location.text = nil
            
        }
        
        if let typeObject = editableCourse["type"] as? PFObject{
            
            self.type = typeObject
            
            guard let typeName = typeObject["name"] as? String else{
                print("Impossible")
                return
            }
            
            self.typeOfCourseLabel.text = typeName
            
        }
        
        if let newNumberPart = editableCourse["places"] as? Int{
            
            self.availablePlaces.text = String(newNumberPart)
            
        }else{
            
            self.availablePlaces.text = nil
            
        }
        
        if let newPrice = editableCourse["price"] as? String{
            
            let newPrice2 = newPrice.replacingOccurrences(of: "$", with: "")
            let newPrice3 = newPrice2.replacingOccurrences(of: "MXN", with: "")
            let newPrice4 = newPrice3.replacingOccurrences(of: " ", with: "")
            
            if let actualPrice = Double(newPrice4) {
                
                let userPrice1 = actualPrice/percent
                
                self.costByUser.text = String(userPrice1)
                
                if( self.minimumCost > Double(self.costByUser.text!)! ){
                    
                    self.costByUser.textColor = UIColor.red
                    
                }else{
                    
                    if self.traitCollection.userInterfaceStyle == .dark {
                        // User Interface is Dark
                        self.costByUser.textColor = UIColor.white
                        
                    } else {
                        // User Interface is Light
                        self.costByUser.textColor = UIColor.black
                    }
                    
                }
                
                self.actualCost.text = newPrice3
                
            } else {
                
                print("Error")
                
            }
            
            
            
        }else{
            self.actualCost.text = nil
        }
        
        if let newSpecialRequirements = editableCourse["specialRequirements"] as? String{
            
            self.specialRequirements.text = newSpecialRequirements
            
        }else{
            
            self.specialRequirements.text = nil
            
        }
        
        self.dismissHUD(isAnimated: true)
        
    }
    
    //MARK: GET PERCENTAGES
    
    func getPercentageAndMinimunCost(){
        
        let queryGlobal = PFQuery(className: "Global")
        
        queryGlobal.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.dismissHUD(isAnimated: true)
                self.sendErrorTypeAndDismiss(error: error)
            } else if let object = object {
                // The find succeeded.
                
                if let newPercent = object["percentCost"] as? Double{
                    
                    self.percent = newPercent
                    
                }
                
                if let newMinimumCost = object["minimumCost"] as? Double{
                    
                    self.minimumCost = newMinimumCost
                    
                }
                
                if(self.isNew == false){
                    
                    self.titleUp.text = ""
                    self.updateView()
                    
                }
                
            }
            
        }
        
    }
    
    func checkAllData() -> Bool{
        
        if( logo.image == nil || (logo.image?.isEqual(imageCompare))! || name.text == nil || name.text == "" || smallDescription.text == nil || smallDescription.text == "" || fullDescription.text == nil || fullDescription.text ==  "" || timeDate.text == nil || timeDate.text == "" || durationLabel.text == nil || durationLabel.text == "" || location.text == "" || location.text == nil || availablePlaces.text == nil || availablePlaces.text == "" || costByUser.text == nil || costByUser.text == "" || actualCost.text == nil || actualCost.text == "" || specialRequirements.text == nil || specialRequirements.text == "" || typeOfCourseLabel.text == nil || typeOfCourseLabel.text == "" ){
            
            return false
            
        }else{
            
            return true
            
        }
        
    }
    
    func createDatePicker(){
        
        self.datePickerView.locale = Locale(identifier: "es_ES")
        self.datePickerView.timeZone = NSTimeZone.local
        
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .month, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .hour, value: 0, to: Date())
        self.datePickerView.minimumDate = Calendar.current.date(byAdding: .minute, value: 0, to: Date())
        
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
        //self.endSchedule = self.datePickerView.date.addingTimeInterval(timeValue*60*60)
        
        self.view.endEditing(true)
        
    }
    
    // MARK: TABLE FUNCTIONS
    
    func queries(){
        
        let queryCities = PFQuery(className: "Type")
        
        queryCities.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.courseTypesArray = object
            }
            
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

// MARK: TABLEVIEW EXTENSION

extension yoberCreateEditCourse: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "type"){
            
            return courseTypesArray.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "type"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = courseTypesArray[indexPath.item]["name"] as? String
            cell.textLabel?.font = typeOfCourseLabel.font
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "type"){
            
            if let newNameCauses : String = courseTypesArray[indexPath.item]["name"] as? String{
                
                typeOfCourseLabel.text = newNameCauses
                self.type = courseTypesArray[indexPath.item]
                removeTableView()
                
            }else{
                
                print("It didnt work")
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

extension yoberCreateEditCourse{
    
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
