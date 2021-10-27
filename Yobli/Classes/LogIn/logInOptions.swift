//
//  logInOptions.swift
//  Yobli
//
//  Created by Humberto on 7/8/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

/* MARK: MAIN INFORMATION
 
 Class logInOptions
 
 It let you go to two new views: logInMain or to the tabBarYobli, the first one is done by connecting directly from the Main storyboard, in the case of the second is thanks to the code in the function logInWFacebook.
 
 Variables:
 
 Outlet weak var termsAndConditions - TextView that it is empty and be later be fill to hold a clickable text (this one is the same in ViewController, refer to it if you have any doubts about how it works)
 
 Functions:
 
 viewDidLoad - Main func, it also contain the text that will be contained in the termsAndCondition variable.
 
 textView - Inside this class will be the specifications on what will happen when the clickable text is press.
 
 logInWFacebook - function connected to the "Iniciar sesion con Facebook" button. Inside this function the user will gain the possiblity to use facebook as a login method combined with parse. In case the user is not registered, it will give the chance to create a new account.
 
 goBack - function with the purpose to send the user back to the previous view, connected to an arrow button at the top of the view
 
 */

import Foundation
import UIKit
import Parse
import FBSDKCoreKit
//import FBSDKLoginKit
import Firebase
import FirebaseAuth
import AuthenticationServices
import KeychainAccess
import CryptoKit
import AuthenticationServices

class logInOptions: UIViewController, UITextViewDelegate{
    
    //MARK: OUTLETS
    
    @IBOutlet weak var termsAndConditions: UITextView!
    @IBOutlet weak var logWMailButton: UIButton!
    @IBOutlet weak var logWFBButton: UIButton!
    @IBOutlet weak var logAppleButton: UIButton!
    
    //MARK: VARs/LETs
    
    let support = supportView()
    private var currentNonce: String?
    
    //MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        termsAndConditions.delegate = self
            
        termsAndConditions.textColor = UIColor.init(hexString: "#0C0C0C")
        
        if self.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            //termsAndConditions.textColor = UIColor.white
            logWFBButton.tintColor = UIColor.white
        } else {
            // User Interface is Light
            //termsAndConditions.textColor = UIColor.black
            logWFBButton.tintColor = UIColor.black
        }
        
        self.dismissWithSwipe()
        
        if #available(iOS 13.0, *) {
            self.logAppleButton.isHidden = false
        } else {
            self.logAppleButton.isHidden = true
        }
    }
    
    enum LinkType: String {
        case termsAndConditions
        case privacyPolicy
    }
    
    //MARK: BUTTON FUNCTIONS
    
    @IBOutlet weak var termsHyperlinkTextView: UITextView! {
        didSet {
            
            termsAndConditions.hyperLink(originalText: "Al presionar Crear cuenta o Iniciar sesión, aceptas nuestros Términos y Condiciones y nuestro Aviso de Privacidad.",
                                                linkTextsAndTypes: ["Términos y Condiciones": LinkType.termsAndConditions.rawValue,
                                                                     "Aviso de Privacidad": LinkType.privacyPolicy.rawValue])
                
            termsAndConditions.textAlignment = .center
            termsAndConditions.font = UIFont(name: "Avenir Medium", size: 13)
            termsAndConditions.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "#087EFC")]
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func logInMail(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "logInMainM") as? logInMainM
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func logInWFacebook(_ sender: Any) {
        
        self.logInFacebookParse()
        
    }
    
    //MARK: - Apple
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    @available(iOS 13.0, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    @IBAction func loginApple(_ sender: UIButton) {
        
        if #available(iOS 13, *) {
            
            self.currentNonce = randomNonceString()
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(self.currentNonce!)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loginParse(email: String, userPassword: String) {
        
        PFUser.logInWithUsername(inBackground: email , password: userPassword) {
            (user: PFUser?, error: Error?) -> Void in
            if user != nil {
                //print("existe")
                
                let tabBarYobli = self.storyboard?.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tabBarYobli
            } else {
                //print("no existe")
            }
        }
    }
    //MARK: LOGIN FUNCTIONS
    
    func logInFacebookParse(){
        
        let permissions = ["public_profile", "email"] //Here the list of permissions we want to read from facebook
        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) {(user: PFUser?, error: Error?) in
            
            if error == nil {
                
                if let user = user {
                    
                    if user.isNew {
                        
                        if (AccessToken.current != nil) {
                            
                            let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, first_name, last_name"])
                            
                            request.start(completionHandler: { (connection, result, error) in
                                
                                if error == nil {
                                    
                                    if let result_dic = result as? NSDictionary {
                                        //Setting Parse name
                                        
                                        if let user_first_name = result_dic["first_name"] as? String {
                                            if let user_last_name = result_dic["last_name"] as? String {
                                                user.username = "\(user_first_name) \(user_last_name)"
                                            }
                                        }
                                        
                                        if let user_email = result_dic["email"] as? String {
                                           user.setValue(user_email, forKey: "email")
                                           user.setValue(self.support.dummyPassword, forKey: "password")
                                        }
                                        
                                        if let user_id = result_dic["id"] as? String {
                                            
                                            let userProfile = "https://graph.facebook.com/" + user_id + "/picture?width=800&height=800"
                                            let profilePictureUrl = NSURL(string: userProfile)
                                            let profilePictureData = NSData(contentsOf: profilePictureUrl! as URL)
                                            
                                            if(profilePictureData != nil){
                                                
                                                let pictureFile = PFFileObject(name: "MainPhoto.jpeg", data: profilePictureData! as Data)
                                                user["userPhoto"] = pictureFile
                                                
                                            }
                                            
                                        }
                                        
                                        //Saving user
                                        
                                        user.saveInBackground {(success: Bool, error: Error?) in
                                            
                                            if let error = error {

                                                // Handle error
                                                NSLog(error.localizedDescription)
                                                self.showError(message: error, title: "Error")

                                            } else {
                                                //Firebase
                                                if let objectId = user.objectId {
                                                    
                                                    if let name = user["name"] as? String{
                                                        
                                                        self.logInFacebookFirebase(result_dic: result_dic, objectId: objectId, name: name)
                                                        
                                                    }
                                                    
                                                }
                                                     
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                } else {
                                    
                                    print(error as Any)
                                    
                                }
                                
                            })
                            
                        }
                        
                    } else {
                        
                        guard let isYoberMain = user["yoberMain"] as? Bool else{
                            return
                        }
                        
                        if(isYoberMain == true){
                            
                            self.logInFacebookFirebaseErrorExclusive()
                            
                        }else{
                            
                            self.logInFacebookFirebaseErrorNotExclusive()
                            
                        }
                        
                    }
                    
                }
                
            } else {
                print("parse firts auth error", error as Any)
            }
        }
        
    }
    
    func logInFacebookFirebase(result_dic: NSDictionary, objectId: String, name: String){
        //Firebase
        guard let accessToken = AccessToken.current else {
            print("Failed to get access token")
            return
        }
            
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
        Auth.auth().signIn(with: credential, completion: { (firebaseUser, error) in
            
            if let error = error {
                
                print("Login error: \(error.localizedDescription)")
                
                self.showError(message: error, title: "Login Error")
                
                return
                
            }else{
                
                let chatAccount = YobliUser(name: name, id: objectId)
                
                DBFirebaseController.shared.insertUser(user: chatAccount, completion: { success in
                    if success{
                        
                        if let user_id = result_dic["id"] as? String {
                            
                            let userProfile = "https://graph.facebook.com/" + user_id + "/picture?width=800&height=800"
                            let profilePictureUrl = NSURL(string: userProfile)
                            let profilePictureData = NSData(contentsOf: profilePictureUrl! as URL)
                            
                            if(profilePictureData != nil){
                                
                                let filename = chatAccount.profilePictureName
                                
                                StFirebaseController.shared.uploadProfilePicture(data: profilePictureData! as Data, fileName: filename, complete: { result in
                                    
                                    switch result{
                                    case .success(let downloadURL):
                                        print(downloadURL)
                                        UserDefaults.standard.setValue(downloadURL, forKey: "profile_picture_url")
                                    case .failure(let error):
                                        print("Store manager error: \(error)")
                                    
                                    }
                                    
                                })
                                
                            }
                            
                        }
                        
                    }
                })
                            
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "signInFinalDecision") as? signInFinalDecision
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = viewController
                            
            }
            
        })
             
    }
    
    //MARK: USER IS NOT NEW
    
    //LOGIN USER IS YOBER EXCLUSIVE
    
    func logInFacebookFirebaseErrorExclusive(){
        
        guard let accessToken = AccessToken.current, let user = PFUser.current() else {
           print("Failed to get access token")
           return
        }
       
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
          if let error = error {
            print("Login error: \(error.localizedDescription)")
            self.showError(message: error, title: "Login Error")
            return
          }else{
            
            if let installation = PFInstallation.current() {
                
                if let idInstallation = installation.objectId {
                    
                    if( idInstallation != user["installationString"] as? String ){
                        
                        user.setObject(installation, forKey: "installation")
                        user.setObject(idInstallation, forKey: "installationString")
                        user.saveInBackground()
                        
                    }
                    
                }
                
            }
            
            let storyboard = UIStoryboard(name: "TabProfile", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarYober") as? UITabBarController
            
            viewController?.selectedIndex = 4

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = viewController
            
          }
            
        }
        
    }
    
    //LOGIN USER IS NOT EXCLUSIVE YOBER
    
    func logInFacebookFirebaseErrorNotExclusive(){
        
        guard let accessToken = AccessToken.current, let user = PFUser.current() else {
           print("Failed to get access token")
           return
        }
       
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
          if let error = error {
            print("Login error: \(error.localizedDescription)")
            self.showError(message: error, title: "Login Error")
            return
          }else{
            
            if let installation = PFInstallation.current() {
                
                if let idInstallation = installation.objectId {
                    
                    if( idInstallation != user["installationString"] as? String ){
                        
                        user.setObject(installation, forKey: "installation")
                        user.setObject(idInstallation, forKey: "installationString")
                        user.saveInBackground()
                        
                    }
                    
                }
                
            }
            
            let tabBarYobli = self.storyboard?.instantiateViewController(withIdentifier: "tabBarYobli") as! UITabBarController
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = tabBarYobli
            
          }
            
        }
        
    }
    
//    //MARK: TEXTVIEW FUNCTIONS
//
//    //Terms And Condition func
//
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//
//        if URL.absoluteString == "1"{
//
//            UIApplication.shared.open(Foundation.URL(string: "https://brounie.com/public/files/Aviso-de-Privacidad.pdf")! as URL, options: [:], completionHandler: nil)
//
//        }
//
//        return false
//
//    }
    
    //MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let linkType = LinkType(rawValue: URL.absoluteString) {
            // TODO: handle linktype here with switch or similar.
            
            if linkType.rawValue == "termsAndConditions" {
                UIApplication.shared.open(Foundation.URL(string: "https://www.yobli.com/terminos")! as URL, options: [:], completionHandler: nil)
            }else if linkType.rawValue == "privacyPolicy" {
                UIApplication.shared.open(Foundation.URL(string: "https://www.yobli.com/privacidad")! as URL, options: [:], completionHandler: nil)
            }
        }
        return false
    }
    
    func showError(message: Error, title: String){
        
        let alert = UIAlertController(title: title, message: message.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
}

@available(iOS 13.0, *)
extension logInOptions: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil{
                    print(error?.localizedDescription ?? "")
                    return
                }else{
                    
                    let emailRegistryApple = Auth.auth().currentUser?.email ?? ""
                    
                    print("emailRegistryApple: \(emailRegistryApple)")
                    print("se creo en fireBase")
                    
                    let query = PFQuery(className: "_User")
                    query.whereKey("email", equalTo: emailRegistryApple)
                    query.findObjectsInBackground { (objects, error) in
                        if error == nil {
                            if (objects!.count > 0){
                                print("usuario existente")
                                //self.logIninParse(userMail: emailRegistryApple, userPassword: "12345678")
                                self.loginParse(email: emailRegistryApple, userPassword: emailRegistryApple)
                            } else {
                                print("se creara un usuario")
                                let alert = UIAlertController(title: "¡Alerta!", message: "Aún no creas una cuenta", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else {
                            print("error")
                        }
                    }
                }
            }
        }else{
            print("entre al else")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error Apple: \(error.localizedDescription)")
    }
}
