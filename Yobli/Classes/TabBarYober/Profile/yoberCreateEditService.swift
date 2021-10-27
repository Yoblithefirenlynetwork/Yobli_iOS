//
//  yoberCreateEditService.swift
//  Yobli
//
//  Created by Brounie on 05/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class yoberCreateEditService: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var titleUp: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var fullDescription: UITextView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var addTimeButton: UIButton!
    @IBOutlet weak var susTimeButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categorySubView: UIView!
    @IBOutlet weak var costByUser: UITextField!
    @IBOutlet weak var actualCost: UITextField!
    @IBOutlet weak var numberOfPeople: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var isNew = true
    
    //TABLE LIST VALUES
    
    var editableService = PFObject(className: "Service")
    var serviceCategories = [PFObject]()
    var category : PFObject?
    let tableList = UITableView()
    let transparentView = UIView()
    
    //DATEPICKER
    
    let datePickerView = UIDatePicker()
    var selectedButton = UIButton()
    var buttonSelected = ""
    
    //IMAGE VIEW
    
    var imageCompare = UIImage(named: "imageBackground")
    
    //GENERAL VALUES
    
    var timeValue = 0.0
    var percent = 0.0
    var minimumCost = 0.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.queries()
        self.getPercentageAndMinimunCost()
        
//        if(isNew == false){
//
//            titleUp.text = "Editar Servicio"
//
//            self.showHUD(progressLabel: "Cargando...")
//
//            self.updateView()
//
//        }
        
        if(isNew == false){
            
            self.titleUp.text = ""
            self.logoButton.isHidden = true
            self.name.isUserInteractionEnabled = false
            self.fullDescription.isUserInteractionEnabled = false
            self.addTimeButton.isUserInteractionEnabled = false
            self.susTimeButton.isUserInteractionEnabled = false
            self.costByUser.isUserInteractionEnabled = false
            self.actualCost.isUserInteractionEnabled = false
            self.categoryButton.isUserInteractionEnabled = false
            self.numberOfPeople.isUserInteractionEnabled = false
            self.saveButton.isHidden = true
            
            self.showHUD(progressLabel: "Cargando...")
            
            self.updateView()
            
        }
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        logo.roundCompleteImageColor()
        logoButton.roundCompleteButtonColor()
        
        addTimeButton.roundCompleteButton()
        susTimeButton.roundCompleteButton()
        
        categorySubView.roundCustomView(divider: 32)
        
        name.generalBottomLine()
        costByUser.generalBottomLine()
        actualCost.generalBottomLine()
        numberOfPeople.generalBottomLine()
        fullDescription.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
            
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTOM FUNCTIONS
    
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
    
    
    @IBAction func saveService(_ sender: Any) {
        
        if checkAllData() == false {
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "Los campos no han sido completados", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else if( Double( costByUser.text! )! < minimumCost ){
        
            let alert = UIAlertController(title: "ERROR", message: "El precio del servicio es menor al mínimo de $\(minimumCost).MX", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "ATENCIÓN", message: "No podrás editar el servicio una vez creado", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            let action = UIAlertAction(title: "Aceptar", style: .default){ (_) in
                
                if self.isNew == true {
                    
                    self.saveNew()
                    
                }else{
                    
                    self.saveOld()
                    
                }
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func displayCategoryList(_ sender: Any) {
        
        buttonSelected = "category"
        selectedButton = categoryButton
        
        fillTable(frames: categoryButton.frame, number: serviceCategories.count)
        
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        
        if(costByUser.text != nil && costByUser.text != ""){
            
            let rawCost = Double(costByUser.text!)!
            let fullCost = rawCost * percent
            
            actualCost.text = String(format: "%.2f", fullCost)
            
        }
        
    }
    
    // MARK: SAVE NEW OBJECT
    
    func saveNew(){
        
        self.showHUD(progressLabel: "Guardando Información")
        
        let imageData = logo.image?.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
        editableService["logo"] = imageFile
        editableService["name"] = name.text
        editableService["description"] = fullDescription.text
        editableService["duration"] = durationLabel.text
        editableService["category"] = self.category
        editableService["price"] = "$"+actualCost.text!+" MXN"
        editableService["places"] = Int(numberOfPeople.text!)
        editableService["category_name"] = self.categoryLabel.text
        editableService["private"] = false
        editableService["view"] = 0
        editableService["inscriptions"] = 0
        editableService["active"] = true
    
        guard let user = PFUser.current() else{
            
            self.sendAlert()
            return
            
        }
        
        editableService["yober"] = user
        
        editableService.saveInBackground {  (success: Bool?, error: Error?) in
            
            self.dismissHUD(isAnimated: true)
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                
                let alert = UIAlertController(title: "ÉXITO", message: "Servicio Guardado", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                    
                self.present(alert, animated: true, completion: nil)
                    
                self.logo.image = self.imageCompare
                self.name.text = ""
                self.fullDescription.text = ""
                self.costByUser.text = ""
                self.actualCost.text = ""
                self.durationLabel.text = ""
                self.categoryLabel.text = ""
                self.category = nil
                self.numberOfPeople.text = ""
                
            }
            
        }
        
        
    }
    
    // MARK: SAVE OLD OBJECT
    
    func saveOld(){
        
        self.showHUD(progressLabel: "Guardando Información")
        
        let imageData = logo.image?.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "MainLogo.jpeg", data: imageData!)
        editableService["logo"] = imageFile
        editableService["name"] = name.text
        editableService["description"] = fullDescription.text
        editableService["duration"] = durationLabel.text
        editableService["category"] = self.category
        editableService["price"] = "$"+actualCost.text!+" MXN"
        editableService["places"] = Int(numberOfPeople.text!)
        
        editableService.saveInBackground {  (success: Bool?, error: Error?) in
            
            self.dismissHUD(isAnimated: true)
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                
                let alert = UIAlertController(title: "ÉXITO", message: "Cambios guardados", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    // MARK: UPDATE VIEW
    
    func updateView(){
        
        if let imageInformation = editableService["logo"] as? PFFileObject{
        
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
        
        if let newName = editableService["name"] as? String{
            self.name.text = newName
        }else{
            self.name.text = nil
        }
        
        if let newDescription = editableService["description"] as? String{
            
            self.fullDescription.text = newDescription
            
        }else{
            
            self.fullDescription.text = nil
            
        }
        
        if let newDuration = editableService["duration"] as? String{
            
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
        
        if let categoryObject = editableService["category"] as? PFObject{
            
            self.category = categoryObject
            
            guard let categoryName = categoryObject["name"] as? String else{
                print("Impossible")
                return
            }
            
            self.categoryLabel.text = categoryName
            
        }
        
        if let newPrice = editableService["price"] as? String{
            
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
        
        if let newNumberPart = editableService["places"] as? Int{
            
            self.numberOfPeople.text = String(newNumberPart)
            
        }else{
            
            self.numberOfPeople.text = nil
            
        }
        
        self.dismissHUD(isAnimated: true)
        
    }
    
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
                    
                    //self.titleUp.text = "Editar Servicio"
                    self.updateView()
                    
                }
                
            }
            
        }
        
    }
    
    func checkAllData() -> Bool{
        
        if( logo.image == nil || (logo.image?.isEqual(imageCompare))! || name.text == nil || name.text == "" || fullDescription.text == nil || fullDescription.text ==  "" || durationLabel.text == nil || durationLabel.text == "0.0" || categoryLabel.text == "" || categoryLabel.text == nil || costByUser.text == nil || costByUser.text == "" || actualCost.text == nil || actualCost.text == "" || numberOfPeople.text == nil || numberOfPeople.text == "" ){
            
            return false
            
        }else{
            
            return true
            
        }
        
    }
    
    @IBAction func addTimeDuration(_ sender: Any) {
        
        if(timeValue < 8){
            
            timeValue = timeValue + 0.5
            durationLabel.text = String(timeValue) + " horas"
            
        }
        
    }
    
    @IBAction func susTime(_ sender: Any) {
        
        if(timeValue > 0){
            
            timeValue = timeValue - 0.5
            durationLabel.text = String(timeValue) + " horas"
            
        }
        
    }
    
    
    // MARK: TABLE FUNCTIONS
    
    func queries(){
        
        let queryCities = PFQuery(className: "Category")
        
        queryCities.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.serviceCategories = object
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
    
}

// MARK: TABLEVIEW EXTENSION

extension yoberCreateEditService: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "category"){
            
            return serviceCategories.count
            
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "category"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = serviceCategories[indexPath.item]["name"] as? String
            cell.textLabel?.font = categoryLabel.font
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "category"){
            
            if let newNameCauses : String = serviceCategories[indexPath.item]["name"] as? String{
                
                categoryLabel.text = newNameCauses
                self.category = serviceCategories[indexPath.item]
                removeTableView()
                
            }else{
                
                print("It didnt work")
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(buttonSelected == "category"){
            
            return 50
            
        }
        
        return 60
        
    }
    
}

extension yoberCreateEditService{
    
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
