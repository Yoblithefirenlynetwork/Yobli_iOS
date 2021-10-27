//
//  singInMailImg.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//
/*MARK: MAIN INFORMATION
 
 Class singInMailImg
 
 Class where we will use the camera or the gallery to get and image that will be save in parse later on, also this process can be skiped, meaning that is not a priority.
 
 Variables:
 
 Outlet weak var photoView - With this we can see the picture selected, for default it has a gray image
 
 Outlet weak var photoButton - It has a camera symbol and is the same place and have the same size as the previous var, but is in front of it, to make the user think they are pressing the image.
 
 Functions:
 
 viewDidLoad - Main func, it also contains the code to make the photoButton and photoView circular with a blue border.
 
 sendToNextWP - If the user select the button "Continuar", it will take the image from photoView with the rest of the information saved in the local var variables (password, email ...) and send to the next view, in case the user didnt select anything it will not let you do anything.
 
 sendToNextWP - If the user doesnt want to use a photo right now, it can skip this step and will not make change to the values of the next view, only for the image part.
 
 getPhoto - function connected to the var photoButton, it will let the user select from where he wants to get the photo, being the camera or gallery, also make sure we have access to it, if not it send an error message, it can also be cancel if the user doesnt want to use a photo.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit

class singInMailImg: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var photoButton: UIButton!
    
    // MARK: VARs/LETs
    
    //Variables that will be saved from the previous View
    
    var password = ""
    var email = ""
    var username = ""
    var userDescription = ""
    var imageCompare = UIImage(named: "imageBackground")
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //This part of code is to make the images appear rounded and to add the blue border, remember to put the Content of the imageView in the storyboards as imageFill
        
        photoView.backgroundColor = .lightGray
        
        photoView.roundCompleteImageColor()
        photoButton.roundCompleteButtonColor()
        
        self.dismissWithSwipe()
        
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
    
    //This method is for when the user select: Continuar
    
    @IBAction func sendToNextwP(_ sender: Any) {
        
        //Check if the descriptionString is empty, if it is not it can be saved
        
        if( photoView.image == nil ){
            
            //Send a message that the mail was not given
            
            let alert = UIAlertController(title: "ERROR", message: "No se ha subido una foto", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            
            photoView.backgroundColor = nil
                
            //Send the information to the next view and go to the next view
                
            let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailPh") as? singInMailPh
                
            viewController?.email = email
            viewController?.username = username
            viewController?.password = password
            viewController?.userDescription = userDescription
            viewController?.image = photoView.image!
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }
    }
    
    //This method is for when the user select: Saltar por ahora
    
    @IBAction func sendToNextWoP(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "singInMailPh") as? singInMailPh
        
        viewController?.email = email
        viewController?.username = username
        viewController?.password = password
        viewController?.userDescription = userDescription
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    //MARK: IMAGEVIEW FUNCTIONS
    
    //This method is to get the picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        photoView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
