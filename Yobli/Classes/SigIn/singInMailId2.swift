//
//  singInMailId2.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/* MARK: MAIN INFORMATION
 
 Class singInMailD2
 
 Class where we will send all the information given by the person that want to create a user to save in parse.
 
 Functions:
 
 viewDidLoad - Main func.
 
 createProfile - If the user select the button "Continuar", it will take all the information save in the provitional variables and send it to Parse, it can have somethings empty, excepto for the e-mail and password, note username will be the same as the e-mail, the user can later change that in another view.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Parse
import MBProgressHUD
import Firebase
import FirebaseAuth

class singInMailId2: UIViewController {
    
    // MARK: VARs/LETs
    
    var email = ""
    var password = ""
    var username = ""
    var userDescription = ""
    var image = UIImage(named: "imageBackground")
    var image2 = UIImage()
    var phoneCode = ""
    var phoneNumber = ""
    
    let support = supportView()
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dismissWithSwipe()
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func createProfile(_ sender: Any) {
        
        self.signInParse()
        
    }
    
    //MARK: OTHER FUNCTIONS
    
    
    func signInParse(){
        
        self.showHUD(progressLabel: "Verificando datos...")
        
        let newUser = PFUser() //Call a temporary user to fill
        
        //Fill with the data
        
        newUser.email = email
        newUser.username = email
        newUser.password = self.support.dummyPassword
        newUser["name"] = username
        newUser["userDescription"] = userDescription
        
        print("username: \(username)")
        let imageData = image?.jpegData(compressionQuality: 1.0) //Transform the images to data
        let imageFile = PFFileObject(name: "MainPhoto.jpeg", data: imageData!) //Transform data to a PFFileObject to save
        let imageData2 = image2.jpegData(compressionQuality: 1.0)
        let imageFile2 = PFFileObject(name: "Identification.jpeg", data: imageData2!)
        
        newUser["userPhoto"] = imageFile
        newUser["userPhoneCode"] = phoneCode
        newUser["userPhoneNumber"] = phoneNumber
        newUser["userIdentification"] = imageFile2
        
        newUser.signUpInBackground { (succeeded, error) in
            
            self.dismissHUD(isAnimated: true)
            
            if(succeeded){
                
                if let objectId = newUser.objectId{
                    
                    self.signInFirebase(objectId: objectId)
                    
                }
                
            }else{
                
                let alert = UIAlertController(title: "ERROR", message: error.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func signInFirebase(objectId: String){
        
        self.showHUD(progressLabel: "Creando Usuario...")
        
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
                                print(downloadURL)
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
    
    //MARK: OTHER FUNCTIONS
    
    func logInFirebase(mail: String, password: String){
        
        self.showHUD(progressLabel: "Autenticando usuario...")
        
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
    
}

extension singInMailId2{
    
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
