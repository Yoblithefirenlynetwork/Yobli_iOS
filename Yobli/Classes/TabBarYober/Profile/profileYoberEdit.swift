//
//  profileYoberEdit.swift
//  Yobli
//
//  Created by Brounie on 29/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import Parse
import UIKit
import MBProgressHUD

class profileYoberEdit: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    @IBOutlet weak var yoberName: UILabel!
    @IBOutlet weak var yoberEmail: UILabel!
    @IBOutlet weak var yoberPhone: UILabel!
    @IBOutlet weak var yoberDescription: UITextField!
    @IBOutlet weak var yoberCategoryLabel: UILabel!
    @IBOutlet weak var yoberCategoryButton: UIButton!
    @IBOutlet weak var yoberCategorySubView: UIView!
    @IBOutlet weak var yoberPriceRangeLabel: UILabel!
    @IBOutlet weak var yoberPriceRangeButton: UIButton!
    @IBOutlet weak var yoberPriceRangeSubView: UIView!
    @IBOutlet weak var yoberStateLabel: UILabel!
    @IBOutlet weak var yoberStateButton: UIButton!
    @IBOutlet weak var yoberStateSubView: UIView!
    @IBOutlet weak var yoberCityLabel: UILabel!
    @IBOutlet weak var yoberCityButton: UIButton!
    @IBOutlet weak var yoberCitySubView: UIView!
    @IBOutlet weak var yoberZone: UITextField!
    @IBOutlet weak var contentView: UIView!
    
    //NEW
    
    @IBOutlet weak var rfcTextField: UITextField!
    @IBOutlet weak var bancoLabel: UILabel!
    @IBOutlet weak var bancoButton: UIButton!
    @IBOutlet weak var bancoView: UIView!
    @IBOutlet weak var cuentaClabeTextField: UITextField!
    @IBOutlet weak var idImage: UIImageView!
    
    // MARK: VARs/LETs
    
    var yDescription = ""
    var yOriginalDescription = ""
    var yCategory = ""
    var yOriginalCategory = ""
    var yPriceRange = ""
    var yOriginalRange = ""
    var yState = ""
    var yOriginalState = ""
    var yCity = ""
    var yOriginalCity = ""
    var yZone = ""
    var yOriginalZone = ""
    var yPhoto = UIImage(named: "imageBackground")
    var yOriginalPhoto = UIImage(named: "imageBackground")
    var buttonSelected = ""
    
    var yRFC = ""
    var yOriginalRFC = ""
    var yCuentaClabe = ""
    var yOriginalCuentaClabe = ""
    var yBank = ""
    var yOriginalBank = ""
    
    let priceRangeArray = ["$-$$", "$$-$$$"]
    
    var categoryArray = [PFObject(className: "Category")]
    var bankArray = [String]()
    
    var selectedButton = UIButton()
    
    var cityArray = [String]()
    var stateArray = [String]()
    
    var stateCities = [PFObject(className: "State")]
    
    let tableList = UITableView()
    let transparentView = UIView()
    
    var decisionPhoto = ""
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        self.queries()
        self.queries2()
        
        tableList.delegate = self
        tableList.dataSource = self
        tableList.register(CellForTable.self, forCellReuseIdentifier: "tableCell")
        
        yoberDescription.delegate = self
        yoberZone.delegate = self
        self.rfcTextField.delegate = self
        self.cuentaClabeTextField.delegate = self
        
        profilePicture.roundCompleteImageColor()
        profilePictureButton.roundCompleteButtonColor()
        
        yoberCategoryButton.roundCustomButton(divider: 32)
        yoberCategorySubView.roundCustomView(divider: 32)
        
        yoberPriceRangeButton.roundCustomButton(divider: 32)
        yoberPriceRangeSubView.roundCustomView(divider: 32)
        
        yoberStateButton.roundCustomButton(divider: 32)
        yoberStateSubView.roundCustomView(divider: 32)
        
        yoberCityButton.roundCustomButton(divider: 32)
        yoberCitySubView.roundCustomView(divider: 32)
        
        bancoButton.roundCustomButton(divider: 32)
        bancoView.roundCustomView(divider: 32)
        
        yoberDescription.generalBottomLine()
        yoberZone.generalBottomLine()
        
        self.rfcTextField.generalBottomLine()
        self.cuentaClabeTextField.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
        self.getBank()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil{
            
            self.sendAlert()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func getIdentificationPhoto(_ sender: UIButton) {
        
        decisionPhoto = "identification"
        
        self.imageProvider()
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func getMainPhoto(_ sender: Any) {
        
        decisionPhoto = "perfil"
        
        self.imageProvider()
        
    }
    
    @IBAction func displayCategory(_ sender: UIButton) {
        
        buttonSelected = "category"
        selectedButton = yoberCategoryButton
        
        fillTable(frames: yoberCategoryButton.frame, number: categoryArray.count)
        
    }
    
    @IBAction func displayBank(_ sender: UIButton) {
        
        buttonSelected = "bank"
        selectedButton = bancoButton
        fillTable(frames: bancoButton.frame, number: bankArray.count)
        
    }
    
    @IBAction func displayPriceRange(_ sender: UIButton) {
        
        buttonSelected = "priceRange"
        selectedButton = yoberPriceRangeButton
        
        fillTable(frames: yoberPriceRangeButton.frame, number: priceRangeArray.count)
        
    }
    
    @IBAction func displayState(_ sender: UIButton) {
        
        buttonSelected = "state"
        selectedButton = yoberStateButton
        
        fillTable(frames: yoberStateButton.frame, number: stateArray.count)
        
    }
    
    @IBAction func displayCity(_ sender: UIButton) {
        
        if(yState != ""){
            
            buttonSelected = "city"
            selectedButton = yoberCityButton
            
            self.getCities(stateName: yState)
            
            fillTable(frames: yoberCityButton.frame, number: cityArray.count)
            
        }
        
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        
        if( checkAllData() == true ){
            
            self.saveChangesParse()
            
        }else{
            
            let alert = UIAlertController(title: "ERROR", message: "El nombre de usuario esta vacío", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        let user = PFUser.current()!
        //userPhotoYober
        if let imageInformation = user["userPhoto"] as? PFFileObject{
            
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.profilePicture.image = image                }
            }
        }else{
            self.profilePicture.image = UIImage(named: "imageBackground")
        }
        
        if let imageIdentification = user["userIdentification"] as? PFFileObject {
            
            imageIdentification.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.idImage.image = image                }
            }
            
        }
        
        if let newName = user["name"] as? String {
            
            yoberName.text = newName
            
        }else{
            
            print("Not possible, a user always need a username to be created")
            
        }
        
        if let newEmail = user.email{
            
            yoberEmail.text = newEmail
            
        }else{
            
            print("Not possible, a user always need a username to be created")
            
        }
        
        if let newDescription = user["yoberDescription"] as? String {
            
            yoberDescription.text = newDescription
            yDescription = newDescription
            yOriginalDescription = newDescription
            
        }
        
        if let newRFC = user["rfc"] as? String {
            
            self.rfcTextField.text = newRFC
            self.yRFC = newRFC
            self.yOriginalRFC = newRFC
            
        }
        
        if let newCuentaClabe = user["clabe"] as? String {
            
            self.cuentaClabeTextField.text = newCuentaClabe
            self.yCuentaClabe = newCuentaClabe
            self.yOriginalCuentaClabe = newCuentaClabe
            
        }
        
        if let newBank = user["bank"] as? String {
            
            self.bancoLabel.text = newBank
            self.yBank = newBank
            self.yOriginalBank = newBank
            
        }
        
        if let newCategory = user["category"] as? String {
            
            yoberCategoryLabel.text = newCategory
            yCategory = newCategory
            yOriginalCategory = newCategory
            
        }
        
        if let newPriceRange = user["priceRange"] as? String {
            
            yoberPriceRangeLabel.text = newPriceRange
            yPriceRange = newPriceRange
            yOriginalRange = newPriceRange
            
        }
        
        if let newState = user["state"] as? String {
            
            yoberStateLabel.text = newState
            yState = newState
            yOriginalState = newState
            
        }
        
        if let newCity = user["city"] as? String {
            
            yoberCityLabel.text = newCity
            yCity = newCity
            yOriginalCity = newCity
            
        }
        
        if let newZone = user["zone"] as? String {
            
            yoberZone.text = newZone
            yZone = newZone
            yOriginalZone = newZone
            
        }
        
        if let newPhoneCode = user["userPhoneCode"] as? String, newPhoneCode != ""{
            
            if let newPhoneNumber = user["userPhoneNumber"] as? String, newPhoneNumber != ""{
                
                self.yoberPhone.text = newPhoneCode + " " + newPhoneNumber
                
            }else{
                
                self.yoberPhone.text = "Sin número registrado"
                
            }
            
        }else{
            
            self.yoberPhone.text = "Sin número registrado"
            
        }
        
    }
    
    //MARK: SAVE FUNCTIONS
    
    func checkAllData() -> Bool{
        
        if( yoberName.text == nil || yoberName.text == "" ){
            
            return false
            
        }else{
            
            return true
            
        }
        
    }
    
    func saveChangesParse(){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Guardando Información"
        
        let user = PFUser.current()!
        
        let imageData = self.profilePicture.image?.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "MainPhotoYober.jpeg", data: imageData!)
        //userPhotoYober
        user["userPhoto"] = imageFile
        
        let imageIdetificationData = self.idImage.image?.jpegData(compressionQuality: 1.0)
        let imageIdentificationFile = PFFileObject(name: "Identification.jpeg", data: imageIdetificationData!)
        user["userIdentification"] = imageIdentificationFile
        
//        if( yPhoto!.isEqual(yOriginalPhoto) ){
//
//        }else{
//
//            let imageData = yPhoto?.jpegData(compressionQuality: 1.0)
//            let imageFile = PFFileObject(name: "MainPhoto.jpeg", data: imageData!)
//
//            user["userPhotoYober"] = imageFile
//
//        }
        
        if( yDescription != yOriginalDescription ){
            
            user["yoberDescription"] = yDescription
            
        }
        
        if (yBank != yOriginalBank) {
            
            user["bank"] = yBank
            
        }
        
        if (yRFC != yOriginalRFC) {
            
            user["rfc"] = yRFC
            
        }
        
        if (yCuentaClabe != yOriginalCuentaClabe) {
            
            user["clabe"] = yCuentaClabe
            
        }
        
        if( yCategory != yOriginalCategory ){
            
            user["category"] = yCategory
            
        }
        
        if( yState != yOriginalState ){
            
            user["state"] = yState
            
        }
        
        if( yCity != yOriginalCity ){
            
            user["city"] = yCity
            
        }
        
        if( yZone != yOriginalZone ){
            
            user["zone"] = yZone
            
        }
        
        if( yPriceRange != yOriginalRange ){
            
            user["priceRange"] = yPriceRange
            
        }
        
        user.saveInBackground {  (success: Bool?, error: Error?) in
            
            loader.hide(animated: true)
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                
                if( (self.yPhoto?.isEqual(self.yOriginalPhoto))! ){
                    
                    let alert = UIAlertController(title: "ÉXITO", message: "Información del Usuario Guardada", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    
                    guard let newProfilePicture = self.yPhoto, let data = newProfilePicture.jpegData(compressionQuality: 0.3) else {
                                
                        return
                                
                    }
                    
                    let chatAccount = YobliUser(name: user["name"] as? String ?? "", id: user.objectId!)
                    
                    let filename = chatAccount.profilePictureName
                            
                    StFirebaseController.shared.uploadProfilePicture(data: data, fileName: filename, complete: { result in
                                
                        switch result{
                        case .success(let downloadURL):
                                    
                            let alert = UIAlertController(title: "ÉXITO", message: "Información del Usuario Guardada", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                                        
                            self.present(alert, animated: true, completion: nil)
                                    
                            UserDefaults.standard.setValue(downloadURL, forKey: "profile_picture_url")
                        case .failure(let error):
                            print("Store manager error: \(error)")
                                
                        }
                                
                    })
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: IMAGEPICKER FUNCTIONS
    
    func imageProvider(){
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        if(decisionPhoto == "perfil"){
            
            picker.allowsEditing = true
            profilePicture.image = image
            //uMainPhoto = image
            picker.dismiss(animated: true, completion: nil)
        }else if(decisionPhoto == "identification"){
            
            idImage.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: TABLE FUNCTIONS
    
    func queries(){
        
        let queryState = PFQuery(className: "State")
        
        queryState.findObjectsInBackground{ (objects: [PFObject]!, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let objects = objects {
                // The find succeeded.
                self.stateCities = objects
                
                for object in objects{
                    
                    if let newState = object["name"] as? String{
                        
                        self.stateArray.append(newState)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func queries2(){
        
        let queryCategory = PFQuery(className: "Category")
        
        queryCategory.findObjectsInBackground{ (objects: [PFObject]!, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.categoryArray = object
            }
            
        }
        
    }
    
    func getBank() {
        
        let queryBank = PFQuery(className: "Bank")
        
        queryBank.findObjectsInBackground{ (banks: [PFObject]!, error: Error?) in
            
            if let error = error {
                // Log details of the failure
                self.sendErrorType(error: error)
            } else if let banks = banks {
                // The find succeeded.
                for bank in banks {
                    
                    self.bankArray.append(bank["nameBank"] as? String ?? "")
                }
            }
        }
    }
    
    func getCities(stateName: String){
        
        var x = 0
        
        for state in stateArray{
            
            if(state == stateName){
                
                if let arrayOfCities = stateCities[x]["cities"] as? [String]{
                    
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
    
}

// MARK: EXTENSION TABLEVIEW

extension profileYoberEdit: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(buttonSelected == "state"){
            
            return stateArray.count
            
        }else if(buttonSelected == "city"){
            
            if( yState != ""){
            
                return cityArray.count
                
            }else{
                
                return 0
                
            }
            
        }else if(buttonSelected == "category"){
            
            return categoryArray.count
            
        }else if(buttonSelected == "priceRange"){
            
            return priceRangeArray.count
        
        }else if(buttonSelected == "bank") {
            
            return bankArray.count
            
        }else{
            
            return 0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(buttonSelected == "state"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = stateArray[indexPath.row]
            cell.textLabel?.font = yoberStateLabel.font
            
            return cell
            
        }else if(buttonSelected == "city"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = cityArray[indexPath.row]
            cell.textLabel?.font = yoberCityLabel.font
            
            return cell
            
        }else if(buttonSelected == "priceRange"){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = priceRangeArray[indexPath.row]
            cell.textLabel?.font = yoberPriceRangeLabel.font
            
            return cell
        }else if(buttonSelected == "bank") {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = bankArray[indexPath.row]
            cell.textLabel?.font = bancoLabel.font
            
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
            
            cell.textLabel?.text = categoryArray[indexPath.row]["name"] as? String
            cell.textLabel?.font = yoberCategoryLabel.font
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(buttonSelected == "state"){
            
            yoberStateLabel.text = stateArray[indexPath.row]
            yState = stateArray[indexPath.row]
            yCity = ""
            yoberCityLabel.text = "Ciudad"
            removeTableView()
            
        }else if(buttonSelected == "city"){
                
            yoberCityLabel.text = cityArray[indexPath.row]
            yCity = cityArray[indexPath.row]
            removeTableView()
            
        }else if(buttonSelected == "priceRange"){
        
            yoberPriceRangeLabel.text = priceRangeArray[indexPath.row]
            yPriceRange = priceRangeArray[indexPath.row]
            removeTableView()
        
        }else if(buttonSelected == "bank") {
            
            bancoLabel.text = bankArray[indexPath.row]
            yBank = bankArray[indexPath.row]
            removeTableView()
            
        }else{
            
            if let newNameCategory : String = categoryArray[indexPath.row]["name"] as? String{
                
                yoberCategoryLabel.text = newNameCategory
                yCategory = newNameCategory
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

extension profileYoberEdit: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if( textField == yoberDescription ){
            
            yDescription = yoberDescription.text!
            
        }else if( textField == yoberZone ){
            
            yZone = yoberZone.text!
            
        }else if (textField == cuentaClabeTextField) {
            
            yCuentaClabe = cuentaClabeTextField.text!
            
        }else if (textField == rfcTextField) {
            
            yRFC = rfcTextField.text!
        }
    }
}



