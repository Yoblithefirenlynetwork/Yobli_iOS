//
//  logInMainM.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/* MARK: MAIN INFORMATION
 
 Class logInMainM
 
 It let you go to a new view: tabBarYobli.
 
 Variables:
 
 Outlet weak var userMail - The mail of the user
 Outlet weak var getPasswordBack - It is clickable text to gain access to logInRecoverP
 Outlet weak var userPassword - The user password (not visible)
 
 Functions:
 
 viewDidLoad - Main func, it also contain the text that will be contained in the getPasswordBack variable.
 
 textView - Inside this class will be the specifications on what will happen when the clickable text is press.
 
 logInUser - function connected to the "INICIAR SESION" button. Inside this function the user will gain the possiblity to login using parse.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Parse
import MBProgressHUD
import FirebaseAuth
import Firebase

class logInMainM: UIViewController, UITextViewDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var userMail: UITextField!
    
    @IBOutlet weak var getPasswordBack: UITextView!
    
    @IBOutlet weak var userPassword: UITextField!
    
    // MARK: VARs/LETs
    
    let support = supportView()
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getPasswordBack.delegate = self
        
        let text = "Olvidé mi contraseña"
        
        getPasswordBack.createAttributeText(newText: text, location: 10, length: 10)
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            getPasswordBack.textColor = UIColor.white
        } else {
            // User Interface is Light
            getPasswordBack.textColor = UIColor.black
        }
        
        userMail.generalBottomLine()
        userPassword.generalBottomLine()
        
        self.hideKeyboardWhenTappedAround()
        self.dismissWithSwipe()
        
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func logInUser(_ sender: Any) {
        
        //Check it there is a user or a mail in the textFields
        
        if( (userMail.text?.isEmpty)! || (userPassword.text?.isEmpty)! ){
            
            //Send a message that the mail or password was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha insertado una contraseña o correo de usuario", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            self.logInFirebase(mail: userMail.text!, password: userPassword.text!)
            
        }
    }
    
    //MARK: OTHER FUNCTIONS
    
    func logInFirebase(mail: String, password: String){
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Autenticando..."
        
        Auth.auth().signIn(withEmail: mail, password: password) { (user, error) in
            
            loader.hide(animated: true)
            
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
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Iniciando Sesión"
        
        PFUser.logInWithUsername(inBackground:mail, password:password) {
            (user: PFUser?, error: Error?) -> Void in
            
            loader.hide(animated: true)
            
            if user != nil {
                // After successful login. Go to tabBarYobli or tabBarYober if the User is a yoberMain or not
                
                guard let user = user, let isYoberMain = user["yoberMain"] as? Bool else{
                    return
                }
                
                if let installation = PFInstallation.current() {
                    
                    if let idInstallation = installation.objectId {
                        
                        if( idInstallation != user["installationString"] as? String ){
                            
                            user.setObject(installation, forKey: "installation")
                            user.setObject(idInstallation, forKey: "installationString")
                            user.saveInBackground()
                            
                        }
                        
                    }
                    
                }
                
                if(isYoberMain == true){
                    
                    let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as? UITabBarController
                    
                    viewController?.selectedIndex = 4

                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = viewController
                    
                }else{
                    
                    let tabBarYobli = self.storyboard?.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    appDelegate.window?.rootViewController = tabBarYobli
                    
                }
                
            } else {
                
                //Send an Aler that the information given is wrong
                
                let alert = UIAlertController(title: "ERROR", message: "No se ha insertado una contraseña o correo de usuario correctos", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    //MARK: TEXTVIEW FUNCTIONS
    
    //Get Password Back func
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.absoluteString == "1"{
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "logInRecoverP") as? logInRecoverP
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }
        
        return false
        
    }
    
}
