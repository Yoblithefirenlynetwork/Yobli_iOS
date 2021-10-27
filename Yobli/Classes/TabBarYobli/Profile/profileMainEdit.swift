//
//  profileMainEdit.swift
//  Yobli
//
//  Created by Brounie on 09/10/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD
import Firebase
import FirebaseAuth

class profileMainEdit: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var userMainPhoto: UIImageView!
    @IBOutlet weak var userMainPhotoButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var userPhoneNumberButton: UIButton!
    @IBOutlet weak var identificationPhoto: UIImageView!
    @IBOutlet weak var identificationPhotoButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: VARs/LETs
    
    var uMainPhoto = UIImage(named: "imageBackground")
    var originalPhoto = UIImage(named: "imageBackground")
    var uEmail = ""
    var uDescription = ""
    var originalDescription = ""
    var uPhoneCode = ""
    var originalPhoneCode = ""
    var uPhoneNumber = ""
    var originalPhoneNumber = ""
    
    var decisionPhoto = ""
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.updateView()
        
        userMainPhoto.roundCompleteImageColor()
        userMainPhotoButton.roundCompleteButtonColor()
        
        identificationPhoto.roundCustomImageColor(divider: 32)
        identificationPhotoButton.roundCustomButtonColor(divider: 32)
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil || Auth.auth().currentUser == nil{
         
            self.sendAlert()
            
        }
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func saveData(_ sender: Any) {
           
        self.saveChangesParse()
//        if( savePossible() == true ){
//
//
//
//        }
        
    }
    
    @IBAction func getMainPhoto(_ sender: Any) {
        
        decisionPhoto = "perfil"
        
        self.imageProvider()
        
    }
    
    @IBAction func getIdentificationPhoto(_ sender: Any) {
        
        decisionPhoto = "identification"
        
        self.imageProvider()
        
    }
    
    @IBAction func editPassword(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileEditMPConfirm") as? profileEditMPConfirm
        
        viewController?.decision = "Password"
        viewController?.uEmail = uEmail
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func editNumberButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileEdithNumberViewController") as? ProfileEdithNumberViewController
    
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        let user = PFUser.current()!
        
        if let imageInformation = user["userPhoto"] as? PFFileObject{
            
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.userMainPhoto.image = image
                    self.uMainPhoto = image
                    self.originalPhoto = image
                    
                }
                
            }
            
        }
        
        
        
        if let newName = user["name"] as? String{
            self.userName.text = newName
        }else{
            self.userName.text = nil
        }
        
        if let newEmail = user.email{
            self.userEmail.text = newEmail
            self.uEmail = newEmail
        }else{
            self.userEmail.text = nil
        }
        
        if let newDescription = user["userDescription"] as? String{
            
            self.userDescription.text = newDescription
            self.uDescription = newDescription
            self.originalDescription = newDescription
            
        }else{
            
            self.userDescription.text = nil
            
        }
        
        let phoneCode = user["userPhoneCode"] as? String
        let phone = user["userPhoneNumber"] as? String
        
        let number = (phoneCode ?? "") + " " + (phone ?? "")
        
        print("newPhoneCode: \(phoneCode)")
        if phoneCode == "" {
            self.userPhoneNumberButton.setTitle("Agregar un número telefónico", for: .normal)
        }else{

            self.userPhoneNumberButton.setTitle(number, for: .normal)
            
        }
        
//        if let newPhoneNumber = user["userPhoneNumber"] as? String{
//
//            self.userPhoneNumber.text = newPhoneNumber
//            self.uPhoneNumber = newPhoneNumber
//            self.originalPhoneNumber = newPhoneNumber
//
//        }else{
//
//            self.userPhoneNumber.text = nil
//
//        }
        
        if let newIdentification = user["userIdentification"] as? PFFileObject{
            
            newIdentification.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    print(imageData)
                    
                    let image = UIImage(data: imageData)
                    
                    self.identificationPhoto.image = image
                    
                }
                
            }
            
        }else{
            
            self.identificationPhoto.image = nil
            
        }
        
        
        
    }
    
//    func savePossible() -> Bool{
//
//        if( userPhoneCode.text!.count == 0 || userPhoneCode.text!.count == 3 || userPhoneCode.text == nil ){
//
//            if( userPhoneNumber.text!.count == 0 || userPhoneNumber.text!.count == 10 || userPhoneNumber.text == nil){
//
//                return true
//
//            }else{
//
//                let alert = UIAlertController(title: "ERROR", message: "No se ha dado un número válido", preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
//
//                self.present(alert, animated: true, completion: nil)
//
//            }
//
//            return false
//
//        }else{
//
//            let alert = UIAlertController(title: "ERROR", message: "No se ha dado un código válido", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
//
//            self.present(alert, animated: true, completion: nil)
//
//        }
//
//        return false
//
//    }
    
    //MARK: SAVE FUNCTIONS
    
    
    func saveChangesParse(){
        
        let loader = MBProgressHUD.showAdded(to: self.contentView, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Guardando Información"
        
        let user = PFUser.current()!
        
        if(  (uMainPhoto?.isEqual(originalPhoto))! ){
            
        }else{
            
            let imageData = uMainPhoto?.jpegData(compressionQuality: 1.0)
            let imageFile = PFFileObject(name: "MainPhoto.jpeg", data: imageData!)
            
            user["userPhoto"] = imageFile
        
        }
        
        if( identificationPhoto.image != nil ){
            
            print("No fue considerada nil")
            
            let imageData2 = identificationPhoto.image?.jpegData(compressionQuality: 1.0)
            let imageFile2 = PFFileObject(name: "Identification.jpeg", data: imageData2!)
            
            user["userIdentification"] = imageFile2
            
        }
        
//        if( uPhoneNumber != originalPhoneNumber ){
//
//            user["userPhoneNumber"] = uPhoneNumber
//
//        }
//
//        if( uPhoneCode != originalPhoneCode ){
//
//            user["userPhoneCode"] = uPhoneCode
//            
//        }
        
        if( uDescription != originalDescription ){
            
            user["userDescription"] = uDescription
            
        }
        
        user.saveInBackground {  (success: Bool?, error: Error?) in
            
            if let error = error {
                
                loader.hide(animated: true)
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                
                if( (self.uMainPhoto?.isEqual(self.originalPhoto))! ){
                    
                    loader.hide(animated: true)
                    
                    let alert = UIAlertController(title: "ÉXITO", message: "Información del Usuario Guardada", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                        
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    
                    guard let newProfilePicture = self.uMainPhoto, let data = newProfilePicture.jpegData(compressionQuality: 0.3) else {
                                
                        return
                                
                    }
                    
                    let chatAccount = YobliUser(name: user["name"] as? String ?? "", id: user.objectId!)
                    
                    let filename = chatAccount.profilePictureName
                            
                    StFirebaseController.shared.uploadProfilePicture(data: data, fileName: filename, complete: { result in
                                
                        switch result{
                        case .success(let downloadURL):
                            
                            loader.hide(animated: true)
                            let alert = UIAlertController(title: "ÉXITO", message: "Información del Usuario Guardada", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                                        
                            self.present(alert, animated: true, completion: nil)
                                    
                            UserDefaults.standard.setValue(downloadURL, forKey: "profile_picture_url")
                        case .failure(let error):
                            
                            loader.hide(animated: true)
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
            userMainPhoto.image = image
            uMainPhoto = image
            
        }else if(decisionPhoto == "identification"){
            
            identificationPhoto.image = image
            
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: TEXTVIEW FUNCTIONS

extension profileMainEdit : UITextViewDelegate{
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if(textView == userDescription){
            
            uDescription = userDescription.text!
            
        }
        
    }
    
    
}
