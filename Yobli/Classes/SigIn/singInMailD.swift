//
//  singInMailD.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/*MARK: MAIN INFORMATION
 
 Class singInMailD
 
 Class where we will get a description to save in parse later on, also this process can be skiped, meaning that is not a priority.
 
 Variables:
 
 Outlet weak var descriptionString - textView that will contain the description of the user
 
 Functions:
 
 viewDidLoad - Main func, it also contains the code to make the Description have a placeholder.
 
 sendToNextWD - If the user select the button "Continuar", it will take the description from descriptionString with the rest of the information saved in the local var variables (password, email ...) and send to the next view, in case the user didnt write anything it will not let you continue
 
 sendToNextWoD - If the user doesnt want to use a description right now, it can skip this step and will not make change to the values of the next view, only for the description part.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */


import Foundation
import UIKit

class singInMailD: UIViewController, UITextViewDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var descriptionString: UITextView!
    
    // MARK: VARs/LETs
    
    //Variables that will be modify by the previous view
    var email = ""
    var password = ""
    var username = ""
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        descriptionString.delegate = self
        descriptionString.text = "Descripción del usuario"
        descriptionString.textColor = UIColor.lightGray
        descriptionString.layer.borderColor = UIColor.lightGray.cgColor
        descriptionString.layer.borderWidth = 1
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //descriptionString.generalBottomLine()
        //self.descriptionString.layer.borderWidth = 1.0
        //self.descriptionString.layer.borderColor = UIColor.lightGray.cgColor
        self.descriptionString.layer.backgroundColor = UIColor.white.cgColor
        self.descriptionString.layer.cornerRadius = 10
        self.dismissWithSwipe()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    //This method is for when the user select: Continuar
    
    @IBAction func sendToNextwD(_ sender: Any) {
        
        //Check if the descriptionString is empty, if it is not it can be saved
        
        if( (descriptionString.text?.isEmpty)! || descriptionString.text == "Descripción del usuario"){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha dado una descripcion", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            //Send the information to the next view and go to the next view
            
            let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailImg") as? singInMailImg
            
            viewController?.email = email
            viewController?.username = username
            viewController?.password = password
            viewController?.userDescription = descriptionString.text
            
        self.navigationController?.pushViewController(viewController!, animated: true)
            
        }
    }
    
    //This method is for when the user select: Saltar por ahora
    
    @IBAction func sendToNextWoD(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailImg") as? singInMailImg
        
        viewController?.email = email
        viewController?.username = username
        viewController?.password = password
        
    self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    //OTHER FUNCTIONS
    
    //For the textView edition
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                textView.textColor = UIColor.white
            } else {
                // User Interface is Light
                textView.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = "Descripción del usuario"
            textView.textColor = UIColor.lightGray
        }
    }
    
}
