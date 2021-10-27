//
//  supportView.swift
//  Yobli
//
//  Created by Brounie on 27/11/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse

/*
 
 MARK: INFORMATION
 
 This is a support class that serve to have all extension that can be used by many classes and create classes that can be used in more than one class
 
 */


//MARK: COLORS NOTE

/*
    YOBLI BLUE : UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
 
    YOBLI VOLUNTARY YELLOW: UIColor.init(red: 255/255, green: 223/255, blue: 0, alpha: 1)
 
    YOBLI COURSE VIOLET/PINK : UIColor.init(red: 255/255, green: 0, blue: 149/255, alpha: 1)
*/

//MARK: EXTENSION TEXTFIELD

extension UITextField{
    //Create the lines in the textfields
    
    func createBottomLine(){
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        
    }
    
    func generalBottomLine(){
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        
    }
    
    //Alternative bottom create line
    
    func createBottomLineAlt(){
        
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        border.frame = CGRect(x: self.frame.origin.x,
                              y: self.frame.origin.y+self.frame.height, width: self.frame.width, height: 1)
        border.backgroundColor = UIColor.lightGray
        self.superview?.insertSubview(border, aboveSubview: self)
        
    }
    
}

//MARK: EXTENSION TEXTVIEW

extension UITextView{
    
    func generalBottomLine(){
        
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        border.frame = CGRect(x: self.frame.origin.x,
                              y: self.frame.origin.y+self.frame.height, width: self.frame.width, height: 1)
        border.backgroundColor = UIColor.lightGray
        self.superview?.insertSubview(border, aboveSubview: self)
        
    }
    
    func createAttributeText(newText: String, location: Int, length: Int){
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attributedPhrase = NSMutableAttributedString(string: newText, attributes: [.paragraphStyle: paragraph])
        
        let range = NSRange(location: location, length: length)
        
        attributedPhrase.addAttribute(.link, value: "1", range: range)
        attributedPhrase.addAttribute(.foregroundColor, value: UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1), range: range)
        
        self.attributedText = attributedPhrase
        
    }
    
}

//MARK: EXTENSION VIEWCONTROLLER

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func dismissWithSwipe(){
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture) )
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRight)
        
    }
    
    func restartGestures(){
        
        view.gestureRecognizers = []
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {

            case UISwipeGestureRecognizer.Direction.right:

            _ = navigationController?.popViewController(animated: true)
                
            default:
                break
            }
            
        }
        
    }
    
}

//MARK: EXTENSION UIVIEW

extension UIView{
    
    func roundCompleteView(){
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        
    }
    
    func roundCompleteViewColor(){
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.borderWidth = 3
        
    }
    
    func roundCustomView(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        
    }
    
    func roundCustomViewColor(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.borderWidth = 3
        
    }
    
}

//MARK: EXTENSION BUTTON

extension UIButton{
    
    func roundCustomButton(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        
    }
    
    func roundCustomButtonColor(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.borderWidth = 3
        
    }
    
    func roundCustomBackgroundColor(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
        
    }
    
    func roundCompleteButton(){
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        
    }
    
    func roundCompleteButtonColor(){
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.borderWidth = 3
        
    }
    
    func setImageUser(name: String){
//
//        print("name: \(name)")
//        let path = "images/\(name)_profile_picture.jpeg"
//        StFirebaseController.shared.downloadURL(path: path, completion: { [weak self] result in
//            switch result{
//            case.success(let url):
//                DispatchQueue.main.async {
//                    let data = try? Data(contentsOf: url)
//                    if let imageData = data {
//                        let image = UIImage(data: imageData)
//                        let logoImageView = UIImageView.init(image: image)
//                        logoImageView.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
//                        logoImageView.contentMode = .scaleAspectFill
//                        logoImageView.roundCompleteImageColor()
//                        let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 42)
//                        let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 42)
//                        heightConstraint.isActive = true
//                        widthConstraint.isActive = true
//                        self?.addSubview(logoImageView)
//                    }
//                }
//            case.failure(let error):
//                print("Something went wrong: \(error)")
//            }
//        })
        
        let activityQuery = PFQuery(className: "_User")
        activityQuery.whereKey("objectId", contains: name)
        activityQuery.findObjectsInBackground { (objects, error) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let imageInformation = object["userPhoto"] as? PFFileObject {
                        imageInformation.getDataInBackground { (imageData: Data?, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if let imageData = imageData {
                                let image = UIImage(data: imageData)
                                let logoImageView = UIImageView.init(image: image)
                                logoImageView.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
                                logoImageView.contentMode = .scaleAspectFill
                                logoImageView.roundCompleteImageColor()
                                let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 42)
                                let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 42)
                                heightConstraint.isActive = true
                                widthConstraint.isActive = true
                                self.addSubview(logoImageView)
                            }
                        }
                    } else {
                        print("Something went wrong: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: EXTENSION IMAGEVIEW

extension UIImageView{
    
    func roundCustomImage(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        
    }
    
    func roundCustomImageColor(divider: Int){
        
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.borderWidth = 3
        
    }
    
    func roundCompleteImage(){
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        
    }
    
    func roundCompleteImageColor(){
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        self.layer.borderWidth = 3
        
    }
    
    func gradeResults(id: String){
        
        let queryGrade = PFQuery(className: "Grade")
        
        queryGrade.whereKey("yoberId", equalTo: id)
        
        queryGrade.getFirstObjectInBackground { (object, error) in
            
            if error != nil{
                
                self.image = nil
                
            }else if let object = object{
                
                guard let grade = object["grade"] as? Double else{
                    self.image = nil
                    return
                }
                
                self.image = supportView.getGradeImage(grade: grade)
                
                
            }else{
                
                self.image = nil
                
            }
            
            
        }
        
    }
    
    func gradeResultsWhite(id: String){
        
        let queryGrade = PFQuery(className: "Grade")
        
        queryGrade.whereKey("yoberId", equalTo: id)
        
        queryGrade.getFirstObjectInBackground { (object, error) in
            
            if error != nil{
                
                self.image = nil
                
            }else if let object = object{
                
                guard let grade = object["grade"] as? Double else{
                    self.image = nil
                    return
                }
                
                self.image = supportView.getGradeWhiteImage(grade: grade)
                
                
            }else{
                
                self.image = nil
                
            }
            
            
        }
        
    }
    
}

//MARK: EXTENSION NAVIGATIONITEM

extension UINavigationItem {

  func setTitle(_ title: String, subtitle: String) {

    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont(name: "Avenir", size: 20.0)
    titleLabel.textAlignment = .justified

    let subtitleLabel = UILabel()
    subtitleLabel.text = subtitle
    subtitleLabel.font = UIFont(name: "Avenir", size: 10.0)
    subtitleLabel.textColor = UIColor.gray
    titleLabel.textAlignment = .justified

    let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    stackView.distribution = .equalCentering
    stackView.axis = .vertical

    self.titleView = stackView
    
  }
    
}

extension UIBarButtonItem{
    
    func createPlusService(){
        
        let image = UIImage(named: "plusService")
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 108, height: 42)
        button.setImage(image, for: .normal)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 108)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 42)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        self.customView = button
        
    }
    
    func setImage(name: String){

//        let path = "images/\(name)_profile_picture.jpeg"
//        StFirebaseController.shared.downloadURL(path: path, completion: { [weak self] result in
//            switch result{
//            case.success(let url):
//                DispatchQueue.main.async {
//                    let data = try? Data(contentsOf: url)
//                    if let imageData = data {
//                        let image = UIImage(data: imageData)
//                        let logoImageView = UIImageView.init(image: image)
//                        logoImageView.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
//                        logoImageView.contentMode = .scaleAspectFill
//                        logoImageView.roundCompleteImageColor()
//                        let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 42)
//                        let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 42)
//                        heightConstraint.isActive = true
//                        widthConstraint.isActive = true
//                        self?.customView = logoImageView
//                    }
//                }
//            case.failure(let error):
//                print("Something went wrong: \(error)")
//            }
//        })
        let activityQuery = PFQuery(className: "_User")
        activityQuery.whereKey("objectId", contains: name)
        activityQuery.findObjectsInBackground { (objects, error) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let imageInformation = object["userPhoto"] as? PFFileObject {
                        imageInformation.getDataInBackground { (imageData: Data?, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if let imageData = imageData {
                                let image = UIImage(data: imageData)
                                let logoImageView = UIImageView.init(image: image)
                                logoImageView.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
                                logoImageView.contentMode = .scaleAspectFill
                                logoImageView.roundCompleteImageColor()
                                let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 42)
                                let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 42)
                                heightConstraint.isActive = true
                                widthConstraint.isActive = true
                                self.customView = logoImageView
                            }
                        }
                    } else {
                        print("Something went wrong: \(error)")
                    }
                }
            }
        }
    }
}

//MARK: EXTENSION NAVIGATIONCONTROLLER

extension UINavigationController{
    
    func fadeAnimation(_ viewController: UIViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
        
    }
}

//MARK: SUPPORT CLASS FUNCTIONS

struct gradeYober{
    
    var result : Double
    
    var object : PFObject
    
}

class supportView{
    
    let dummyPassword = "yobliPassword123"
    
    class func getGradeImage(grade: Double) -> UIImage?{
        
        if(grade < 1){
            
            return UIImage(named: "stars0")
            
        }else if( grade >= 1 && grade < 2 ){
            
            return UIImage(named: "stars1")
            
        }else if( grade >= 2 && grade < 3 ){
            
            return UIImage(named: "stars2")
            
        }else if( grade >= 3 && grade < 4 ){
            
            return UIImage(named: "stars3")
            
        }else if( grade >= 4 && grade < 4.5 ){
            
            return UIImage(named: "stars4")
            
        }else{
            
            return UIImage(named: "stars5")
            
        }
        
    }
    
    class func getGradeWhiteImage(grade: Double) -> UIImage?{
        
        if(grade < 1){
            
            return UIImage(named: "starsW0")
            
        }else if( grade >= 1 && grade < 2 ){
            
            return UIImage(named: "starsW1")
            
        }else if( grade >= 2 && grade < 3 ){
            
            return UIImage(named: "starsW2")
            
        }else if( grade >= 3 && grade < 4 ){
            
            return UIImage(named: "starsW3")
            
        }else if( grade >= 4 && grade < 4.5 ){
            
            return UIImage(named: "starsW4")
            
        }else{
            
            return UIImage(named: "starsW5")
            
        }
        
    }
    
    //MARK: BAR GENERATE FOR MESSAGE
    
    class func generateBarContactYober(otherUserId: String, otherUserName: String, userId: String, userName: String, senderSideId: String?, receiverSideId: String?, isNew: Bool ) -> UIViewController{
        
        let viewController = messagePrivate(otherUserId: otherUserId, otherUserName: otherUserName, userId: userId, userName: userName, senderSideId: senderSideId, receiverSideId: receiverSideId)
        
        viewController.isNewConversation = isNew
        
        //RIGHTBUTTON
        
        let image = UIImage(named: "reserveService")
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 108, height: 42)
        button.addTarget(viewController, action: #selector(viewController.goToYoberProfileFromOtherTab), for: .touchUpInside)
        button.setImage(image, for: .normal)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 108)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 42)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let rightButtonPlusService = UIBarButtonItem(customView: button)
        
        //LEFT BUTTON
        
        //First Button - User Image
        
        let buttonGo = UIButton()
        buttonGo.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        
        let widthConstraintGo = buttonGo.widthAnchor.constraint(equalToConstant: 42)
        let heightConstraintGo = buttonGo.heightAnchor.constraint(equalToConstant: 42)
        heightConstraintGo.isActive = true
        widthConstraintGo.isActive = true
        
        buttonGo.setImageUser(name: otherUserId)
        buttonGo.addTarget(viewController, action: #selector(viewController.goToProfileFromImageYober), for: .touchUpInside)
        
        let leftImageUser = UIBarButtonItem(customView: buttonGo)
        
        //Second Button - Return Image
        
        let arrowBack = UIImage(named: "arrowBack")
        let buttonBack = UIButton()
        buttonBack.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        buttonBack.addTarget(viewController, action: #selector(viewController.goBack), for: .touchUpInside)
        buttonBack.setImage(arrowBack, for: .normal)
        
        let widthConstraintBack = buttonBack.widthAnchor.constraint(equalToConstant: 42)
        let heightConstraintBack = buttonBack.heightAnchor.constraint(equalToConstant: 42)
        heightConstraintBack.isActive = true
        widthConstraintBack.isActive = true
        
        let leftButtonBack = UIBarButtonItem(customView: buttonBack)
        
        //ADD BUTTONS AND VIEWS
        
        viewController.navigationItem.setTitle("Conversación", subtitle: otherUserName)
        viewController.navigationItem.rightBarButtonItem = rightButtonPlusService
        viewController.navigationItem.leftBarButtonItems = [leftButtonBack, leftImageUser]
        
        return viewController
        
        
    }
    
    class func generateBarContactYoberAlt(otherUserId: String, otherUserName: String, userId: String, userName: String, senderSideId: String?, receiverSideId: String?, isNew : Bool) -> UIViewController{
        
        let viewController = messagePrivate(otherUserId: otherUserId, otherUserName: otherUserName, userId: userId, userName: userName, senderSideId: senderSideId, receiverSideId: receiverSideId)
        
        viewController.isNewConversation = isNew
        
        //RIGHTBUTTON
        
        /*
        
        let image = UIImage(named: "reserveService")
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 108, height: 42)
        button.addTarget(viewController, action: #selector(viewController.goToYoberProfileFromOtherTab), for: .touchUpInside)
        button.setImage(image, for: .normal)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 108)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 42)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let rightButtonPlusService = UIBarButtonItem(customView: button)
 
         */
        
        //LEFT BUTTON
        
        //First Button - User Image
        
        let buttonGo = UIButton()
        buttonGo.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        
        let widthConstraintGo = buttonGo.widthAnchor.constraint(equalToConstant: 42)
        let heightConstraintGo = buttonGo.heightAnchor.constraint(equalToConstant: 42)
        heightConstraintGo.isActive = true
        widthConstraintGo.isActive = true
        
        buttonGo.setImageUser(name: otherUserId)
        buttonGo.addTarget(viewController, action: #selector(viewController.goToProfileFromImageYober), for: .touchUpInside)
        
        let leftImageUser = UIBarButtonItem(customView: buttonGo)
        
        //Second Button - Return Image
        
        let arrowBack = UIImage(named: "arrowBack")
        let buttonBack = UIButton()
        buttonBack.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        buttonBack.addTarget(viewController, action: #selector(viewController.goBack), for: .touchUpInside)
        buttonBack.setImage(arrowBack, for: .normal)
        
        let widthConstraintBack = buttonBack.widthAnchor.constraint(equalToConstant: 42)
        let heightConstraintBack = buttonBack.heightAnchor.constraint(equalToConstant: 42)
        heightConstraintBack.isActive = true
        widthConstraintBack.isActive = true
        
        let leftButtonBack = UIBarButtonItem(customView: buttonBack)
        
        //ADD BUTTONS AND VIEWS
        
        viewController.navigationItem.setTitle("Conversación", subtitle: otherUserName)
        //viewController.navigationItem.rightBarButtonItem = rightButtonPlusService
        viewController.navigationItem.leftBarButtonItems = [leftButtonBack, leftImageUser]
        
        return viewController
        
    }
    
    class func generateBarContactUser(otherUserId: String, otherUserName: String, userId: String, userName: String, senderSideId: String?, receiverSideId: String?, isNew: Bool) -> UIViewController{
        
        let viewController = messagePrivate(otherUserId: otherUserId, otherUserName: otherUserName, userId: userId, userName: userName, senderSideId: senderSideId, receiverSideId: receiverSideId)
        
        viewController.isNewConversation = isNew
        
        //RIGHTBUTTON
        
        let image = UIImage(named: "plusService")
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 108, height: 42)
        button.addTarget(viewController, action: #selector(viewController.goToCreateService), for: .touchUpInside)
        button.setImage(image, for: .normal)
        
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 108)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 42)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        let rightButtonPlusService = UIBarButtonItem(customView: button)
        
        //LEFT BUTTON
        
        //First Button - User Image
        
        let buttonGo = UIButton()
        buttonGo.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        
        let widthConstraintGo = buttonGo.widthAnchor.constraint(equalToConstant: 42)
        let heightConstraintGo = buttonGo.heightAnchor.constraint(equalToConstant: 42)
        heightConstraintGo.isActive = true
        widthConstraintGo.isActive = true
        
        buttonGo.setImageUser(name: otherUserId)
        buttonGo.addTarget(viewController, action: #selector(viewController.goToProfileFromImageUser), for: .touchUpInside)
        
        let leftImageUser = UIBarButtonItem(customView: buttonGo)
        
        //Second Button - Return Image
        
        let arrowBack = UIImage(named: "arrowBack")
        let buttonBack = UIButton()
        buttonBack.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        buttonBack.addTarget(viewController, action: #selector(viewController.goBack), for: .touchUpInside)
        buttonBack.setImage(arrowBack, for: .normal)
        
        let widthConstraintBack = buttonBack.widthAnchor.constraint(equalToConstant: 42)
        let heightConstraintBack = buttonBack.heightAnchor.constraint(equalToConstant: 42)
        heightConstraintBack.isActive = true
        widthConstraintBack.isActive = true
        
        let leftButtonBack = UIBarButtonItem(customView: buttonBack)
        
        //ADD BUTTONS AND VIEWS
        
        viewController.navigationItem.setTitle("Conversación", subtitle: otherUserName)
        viewController.navigationItem.rightBarButtonItem = rightButtonPlusService
        viewController.navigationItem.leftBarButtonItems = [leftButtonBack, leftImageUser]
        
        return viewController
        
    }
    
    class func orderGradeClass(arrayGrade: [PFObject]) -> [PFObject]{
        
        var newStructArray = [gradeYober]()
        var newArray = [PFObject]()
    
        if let topObject = arrayGrade.first{
            
            //print("First step")
            
            guard let topResult = topObject["numberOfGrades"] as? Double else{
                print("IS EMPTY")
                
                return arrayGrade
            }
            
            //print("Second step")
            
            for gradeIndividual in arrayGrade{
                
                guard let grade = gradeIndividual["grade"] as? Double, let numberOfGrades = gradeIndividual["numberOfGrades"] as? Double else{
                    
                    print("This should not happen, it needs both variables to exists")
                    
                    break
                    
                }
                
                let result = ( grade * numberOfGrades ) / topResult
                
                let newStruct = gradeYober(result: result, object: gradeIndividual)
                
                newStructArray.append(newStruct)
                
            }
            
            //print("Third step")
            
            newStructArray.sort { (first: gradeYober, second: gradeYober) -> Bool in
                return first.result > second.result
            }
            
            //print("Fourth Step")
            
            for individualStruct in newStructArray{
                
                newArray.append(individualStruct.object)
                
            }
            
            //print("Fifth Step")
            
            return newArray
            
        }
        
        return arrayGrade
    
    }
    
    //MARK: NOTIFICATION RESERVATION
    
    class func updateReservation(newDate: Date, originalDate: Date, activityId: String, activityType: String){
        
        let params = NSMutableDictionary()
        
        params.setObject(activityId, forKey: "activity_id" as NSCopying)
        params.setObject(activityType, forKey: "activity_type" as NSCopying)
        params.setObject(newDate, forKey: "new_date" as NSCopying)
        params.setObject(originalDate, forKey: "original_date" as NSCopying)
        
        PFCloud.callFunction(inBackground: "reservationsUpdate", withParameters: params as [NSObject : AnyObject], block:{ (results, error)  -> Void in
            
            if let error = error{
                
                print("Error at Update Reservation")
                print(error.localizedDescription)
                
            }else{
                
                print("It send the Notification")
                
            }
            
        })
        
    }
    
}
