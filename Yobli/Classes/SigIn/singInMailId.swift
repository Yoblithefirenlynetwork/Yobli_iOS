//
//  singInMailId.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class singInMailD
 
 Class where we will get an identification as an image to save in parse later on, also this process can be skiped, meaning that is not a priority.
 
 Variables:
 
 Outlet weak var privacyAnnouncement - TextView that it is empty and be later be fill to hold a clickable text (this one is the same in ViewController, refer to it if you have any doubts about how it works)
 
 Outlet weak var idImage - imageView that will be used to get to show and get the identification from the user
 
 Outlet weak var idButtonImage - Button tha will be used to get access to the camera or photo gallery to retrieve an image that will be used as identification to be show on idImage
 
 Functions:
 
 viewDidLoad - Main func.
 
 sendToNextWId - If the user select the button "Continuar", it will take the identification from idImage with the rest of the information saved in the local var variables (password, email ...) and send to the next view, in case the user didnt add anything it will not let you continue.
 
 chargeProfile - If the user doesnt want to use an identification right now, it will take the information given previously and create the new user, but making sure is not a user already created, if something goes wrong it will send an error.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Parse
import MBProgressHUD
import Firebase
import FirebaseAuth

class singInMailId: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var idImage: UIImageView!
    
    @IBOutlet weak var idButtonImage: UIButton!
    
    @IBOutlet weak var privacyAnnouncement: UITextView!
    
    //MARK: VARs/LETs
    
    //Variables modifiable by the previous view
    var email = ""
    var password = ""
    var username = ""
    var userDescription = ""
    var image = UIImage(named: "imageBackground")
    var imageID = UIImage()
    var phoneCode = ""
    var phoneNumber = ""
    let support = supportView()
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //idImage part
        
        //This part of code is to make the images appear rounded and to add the blue border, remember to put the Content of the imageView in the storyboards as imageFill
        
//        idImage.roundCustomImageColor(divider: 16)
//        idImage.backgroundColor = .lightGray
//        idButtonImage.roundCustomButtonColor(divider: 16)
        
        //PrivacyAnnouncement part
        
        privacyAnnouncement.delegate = self
        
        let text = "Aviso de Privacidad de Datos."
        
        privacyAnnouncement.createAttributeText(newText: text, location: 0, length: 5)
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            privacyAnnouncement.textColor = UIColor.white
        } else {
            // User Interface is Light
            privacyAnnouncement.textColor = UIColor.black
        }
        
        self.dismissWithSwipe()
        
    }
    
    // MARK: BUTTON FUNCTION
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func getIdImage(_ sender: Any) {
        
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
    
    
    
    @IBAction func sendToNextwId(_ sender: Any) {
        
        //Check if the phoneCode and phoneNumber are empty, if they are not, they can be saved
        
        if( idImage.image == nil ){
            
            //Send a message that the number was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha cargado ninguna ID", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            idImage.backgroundColor = nil
            
            //Send the information to the next view and go to the next view
                
            let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailId2") as? singInMailId2
                
            viewController?.email = email
            viewController?.password = password
            viewController?.username = username
            viewController?.userDescription = userDescription
            viewController?.image = image
            viewController?.phoneNumber = phoneNumber
            viewController?.phoneCode = phoneCode
            viewController?.image2 = idImage.image!
                
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }
        
    }
    
    @IBAction func chargeProfile(_ sender: Any) {
        
        self.signInParse()
        
    }
    
    //MARK: SING IN PARSE
    
    
    func signInParse(){
        
        self.showHUD(progressLabel: "Creando Usuario...")
        
        let newUser = PFUser()
        newUser.email = email
        newUser.username = email
        newUser["name"] = username
        newUser.password = self.support.dummyPassword
        newUser["userDescription"] = userDescription
        let imageData = image?.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "MainPhoto.jpeg", data: imageData!)
        newUser["userPhoto"] = imageFile
        newUser["userPhoneCode"] = phoneCode
        newUser["userPhoneNumber"] = phoneNumber
        
        newUser.signUpInBackground { (succeeded, error) in
            
            self.dismissHUD(isAnimated: true)
            
            if(succeeded){
                
                if let objectId = newUser.objectId{
                    
                    self.signInFirebase(objectId: objectId)
                    
                }
                
            }else if let error = error{
                print("error username")
                self.sendErrorType(error: error)
                
            }
        }
    }
    
    //MARK: SIGN IN FIREBASE
    
    func signInFirebase(objectId: String){
        
        self.showHUD(progressLabel: "Guardando información...")
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if(user != nil){
                
                let chatAccount = YobliUser(name: self.username, id: objectId)
                
                DBFirebaseController.shared.insertUser(user: chatAccount, completion: { success in
                    if success{
                        
                        guard let newProfilePicture = self.image, let data = newProfilePicture.jpegData(compressionQuality: 0.3) else {
                            
                            return
                            
                        }
                        
                        let filename = chatAccount.profilePictureName
                        
                        StFirebaseController.shared.uploadProfilePicture(data: data, fileName: filename, complete: { result in
                            
                            switch result{
                            case .success(let downloadURL):
                                UserDefaults.standard.setValue(downloadURL, forKey: "profile_picture_url")
                            case .failure(let error):
                                print("Store manager error: \(error)")
                            
                            }
                            
                        })
                        
                    }
                })
                
                self.dismissHUD(isAnimated: true)
                
                self.logInFirebase(mail: self.email, password: self.password)
                
            }else{
                
                self.dismissHUD(isAnimated: true)
                
                if let error = error?.localizedDescription{
                    
                    let alert = UIAlertController(title: "ERROR", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                    
                }else{
                    print("error interno")
                }
                
            }
        }
    }
    
    //MARK: LOG IN FIREBASE
    
    func logInFirebase(mail: String, password: String){
        
        self.showHUD(progressLabel: "Verificando Usuario...")
        
        Auth.auth().signIn(withEmail: mail, password: password) { (user, error) in
            
            self.dismissHUD(isAnimated: true)
            
            if user != nil {
                
                self.logInParse(mail: mail, password: self.support.dummyPassword)
                
            }else{
                
                if let error = error?.localizedDescription{
                    
                    let alert = UIAlertController(title: "ERROR", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                    
                }else{
                    print("error interno")
                }
                
            }
        }
        
    }
    
    //MARK: LOG IN PARSE
    
    func logInParse(mail: String, password: String){
        
        self.showHUD(progressLabel: "Iniciando sesión...")
        
        PFUser.logInWithUsername(inBackground:mail, password:password) {
            (user: PFUser?, error: Error?) -> Void in
            
            self.dismissHUD(isAnimated: true)
            
            if user != nil {
                // After successful login. Go to tabBarYobli
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "signInFinalDecision") as? signInFinalDecision
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = viewController
                
            } else if let error = error{
                
                //Send an Aler that the information given is wrong
                
                let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    // MARK: TEXTVIEW FUNCTIONS
    
    //Privacy Announcement Func
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.absoluteString == "1"{
            
            UIApplication.shared.open(Foundation.URL(string: "https://brounie.com/public/files/Aviso-de-Privacidad.pdf")! as URL, options: [:], completionHandler: nil)
            
        }
        
        return false
        
    }
    
    //MARK: IMAGEVIEW FUNCTIONS
    
    //This method is to get the picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        idImage.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension singInMailId{
    
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
