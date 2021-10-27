//
//  profileYoberMain.swift
//  Yobli
//
//  Created by Brounie on 25/09/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD
import FirebaseAuth
import Firebase

class profileYoberMain: UIViewController{
    
    // MARK: OUTLETS
    
    @IBOutlet weak var avisoPopUpView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var camaraIconImage: UIImageView!
    @IBOutlet weak var yoberName: UILabel!
    @IBOutlet weak var yoberDescription: UILabel!
    @IBOutlet weak var yoberDetails: UILabel!
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var yoberCourseCollection: UICollectionView!
    @IBOutlet weak var yoberServiceCollection: UICollectionView!
    @IBOutlet weak var yoberGalleryCollection: UICollectionView!
    @IBOutlet weak var yoberVoluntaryCollection: UICollectionView!
    
    
    // MARK: VARs/LETs
    
    var yoberCoursesArray = [PFObject]()
    var yoberServicesArray = [PFObject]()
    var yoberGalleryArray = [PFObject]()
    var yoberVoluntaryArray = [PFObject]()
    
    //var datesArrayString = [String]()
    
    var scheduleArray = [Schedule]()
    var scheduleValuntaryArray = [Schedule]()
    var isCanCreate = false
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateView()
        self.checkInfo()
        
        profilePicture.roundCompleteImageColor()
        
        yoberCourseCollection.dataSource = self
        yoberCourseCollection.delegate = self
        yoberServiceCollection.dataSource = self
        yoberServiceCollection.delegate = self
        yoberGalleryCollection.dataSource = self
        yoberGalleryCollection.delegate = self
        yoberVoluntaryCollection.dataSource = self
        yoberVoluntaryCollection.delegate = self
        
        self.avisoPopUpView.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateView()
        self.checkInfo()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1).cgColor
        profilePicture.layer.borderWidth = 3
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
            
            self.sendAlert()
            
        }
    }
    
    //MARK: - ActionsPopupView
    
    @IBAction func closedPopUpButton(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.avisoPopUpView.isHidden = true
        })
    
    }
    @IBAction func acceptPopUpButton(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.avisoPopUpView.isHidden = true
        })
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func goBackToTabUser(_ sender: Any) {
        
        guard let user = PFUser.current(), let isYoberExclusive = user["yoberExclusive"] as? Bool else{
            
            self.sendAlert()
            
            return
            
        }
        
        user["iAmInYober"] = false
        
        user.saveInBackground {  (success: Bool?, error: Error?) in
            
            if let error = error {
                
                print(error)
                
            }else if success != nil{
                print("no esta en yober")
            }
        }
        
        if( isYoberExclusive == false ){
            
            let goTo = UIStoryboard(name: "TabYoberProfile", bundle: nil).instantiateViewController(withIdentifier: "profileYoberChangeUser") as! profileYoberChangeUser
            
            let nav = UINavigationController(rootViewController: goTo)
            
            nav.isNavigationBarHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = nav
            
        }else{
            
            let alert = UIAlertController(title: "ATENCIÓN", message: "Tú cuenta ahora también será Usuario, ¿Estás seguro/a?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
            
            let action = UIAlertAction(title: "Volverse Usuario", style: .default){ (_) in
                
                let goTo = UIStoryboard(name: "TabYoberProfile", bundle: nil).instantiateViewController(withIdentifier: "profileYoberChangeUser") as! profileYoberChangeUser
                
                let nav = UINavigationController(rootViewController: goTo)
                
                nav.isNavigationBarHidden = true
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                appDelegate.window?.rootViewController = nav
                
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func sendSOS(_ sender: Any) {
        
        let alert = UIAlertController(title: "ATENCIÓN", message: "¿Está seguro/a de llamar a emergencias?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        let action = UIAlertAction(title: "Contactar", style: .default){ (_) in
            
            guard let number = URL(string: "tel://" + "911") else {
                return
            }
            
            UIApplication.shared.open(number)
            
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func logOut(_ sender: Any) {
        
        try!
            Auth.auth().signOut()
        PFUser.logOut()
        
        let goTo = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        let nav = UINavigationController(rootViewController: goTo)
        
        nav.isNavigationBarHidden = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = nav
        
    }
    
    // MARK: OTHER FUNCTIONS
    
    func updateView(){
        
        //self.profilePicture.image = UIImage(named: "imageBackground")
        
        let user = PFUser.current()!
        //userPhotoYober
        if let imageInformation = user["userPhoto"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                
                    let image = UIImage(data: imageData)
                    
                    self.profilePicture.image = image
                    //self.camaraIconImage.alpha = 0.0
                }
                
            }
        
        }else{
            
            self.profilePicture.image = UIImage(named: "imageBackground")
            //self.camaraIconImage.alpha = 1.0
            
        }
        
        if let newName = user["name"] as? String {
            
            yoberName.text = newName
            
        }else{
            
            print("Not possible, a user always need a username to be created")
            
        }
        
        if let newDescription = user["yoberDescription"] as? String {
            
            yoberDescription.text = newDescription
            
        }else{
            
            print("This is possible, the yober can edit it's description later")
            
        }
        
        if let newCategory = user["category"] as? String{
            
            if let newPriceRange = user["priceRange"] as? String{
                
                if let newState = user["state"] as? String{
                    
                    if let newCity = user["city"] as? String{
                        
                        if let newZone = user["zone"] as? String{
                            
                            self.yoberDetails.text = newCategory + " | " + newPriceRange + " | " + newState + ", " + newCity + ", " + newZone
                            
                        }
                        else{
                            
                            self.yoberDetails.text = newCategory + " | " + newPriceRange + " | " + newState + ", " + newCity
                            
                        }
                        
                    }else{
                        
                        self.yoberDetails.text = newCategory + " | " + newPriceRange + " | " + newState
                        
                    }
                    
                    
                }else{
                    
                    self.yoberDetails.text = newCategory + " | " + newPriceRange
                    
                    
                }
                
            }else{
                
                self.yoberDetails.text = newCategory
                
            }
            
        }else if let newPriceRange = user["priceRange"] as? String{
            
            if let newState = user["state"] as? String{
                
                if let newCity = user["city"] as? String{
                    
                    if let newZone = user["zone"] as? String{
                        
                        self.yoberDetails.text = newPriceRange + " | " + newState + ", " + newCity + ", " + newZone
                        
                    }
                    else{
                        
                        self.yoberDetails.text = newPriceRange + " | " + newState + ", " + newCity
                        
                    }
                    
                }else{
                    
                    self.yoberDetails.text = newPriceRange + " | " + newState
                    
                }
                
                
            }else{
                
                self.yoberDetails.text = newPriceRange
                
                
            }
            
        }else if let newState = user["state"] as? String{
            
            if let newCity = user["city"] as? String{
                
                if let newZone = user["zone"] as? String{
                    
                    self.yoberDetails.text = newState + ", " + newCity + ", " + newZone
                    
                }
                else{
                    
                    self.yoberDetails.text = newState + ", " + newCity
                    
                }
                
            }else{
                
                self.yoberDetails.text = newState
                
            }
            
            
        }
        
        
        getContent(yober: user)
        self.yoberGrade.gradeResults(id: user.objectId!)
        
        
        
    }
    
    func getContent(yober : PFObject){
        
        //Query to get the Course on the Database
        
        let date = Date()
        let queryCourse = PFQuery(className:"Course")
        queryCourse.whereKey("yober", equalTo: yober)
        queryCourse.whereKey("date", greaterThan: date)
        queryCourse.includeKey("type")
        
        queryCourse.findObjectsInBackground { (objects: [PFObject]!, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
            
                self.scheduleArray = [Schedule]()
                
                for object in objects {
                    let date = object["date"] as? Date
                    let endDate = object["endDate"] as? Date
                    
                    self.scheduleArray.append(Schedule(startSchedule: date ?? Date(), endSchedule: endDate ?? Date()))
                    
                }
                //print("scheduleArray: \(self.scheduleArray)")
                
                self.yoberCoursesArray = object
            }
            
            self.yoberCourseCollection.reloadData()
            
        }
        
        //Query to get the Services on the Database
        
        let queryService = PFQuery(className:"Service")
        queryService.whereKey("yober", equalTo: yober)
        queryService.whereKey("private", equalTo: false)
        queryService.includeKey("category")
        
        queryService.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.yoberServicesArray = object
                
            }
            
            self.yoberServiceCollection.reloadData()
            
        }
        
        
        //Query to get the Gallery on the Database
        
        let queryGallery = PFQuery(className: "Gallery")
        
        queryGallery.whereKey("yober" , equalTo: yober)
        
        queryGallery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.yoberGalleryArray = object
                
            }
            
            self.yoberGalleryCollection.reloadData()
            
        }
        
        //Query to get the Voluntary on the Database
        
        let queryVoluntary = PFQuery(className:"Voluntary")
        queryVoluntary.whereKey("yober", equalTo: yober)
        queryVoluntary.whereKey("date", greaterThan: date)
        queryVoluntary.includeKey("cause")
        
        queryVoluntary.findObjectsInBackground { (objects: [PFObject]!, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
                
                
                self.scheduleValuntaryArray = [Schedule]()
                
                for object in objects {
                    let date = object["date"] as? Date
                    let endDate = object["endDate"] as? Date
                    
                    self.scheduleValuntaryArray.append(Schedule(startSchedule: date ?? Date(), endSchedule: endDate ?? Date()))
                    
                }
                //print("scheduleValuntaryArray: \(self.scheduleValuntaryArray)")
                
                self.yoberVoluntaryArray = object
     
            }
            
            self.yoberVoluntaryCollection.reloadData()
            
        }
        
    }
    
    func updateGallery(yober: PFObject){
        
        //Query to get the Gallery on the Database
        
        let queryGallery = PFQuery(className: "Gallery")
        
        queryGallery.whereKey("yober" , equalTo: yober)
        
        queryGallery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeExpected(error: error)
            } else if let object = objects {
                // The find succeeded.
                self.yoberGalleryArray = object
                
            }
            
            self.yoberGalleryCollection.reloadData()
            
        }
        
    }
    
    func dateFormat(date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "es_MX")
        dateFormatter.dateFormat = "EEEE dd, MMMM yyyy HH:mm"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        
        let labelDate = dateFormatter.string(from: date)
        
        return labelDate
        
    }
    
    func checkInfo() {
        
        let user = PFUser.current()!
        
        if user["userIdentification"] as? PFFileObject == nil || user["city"] as? String == "" || user["zone"] as? String == "" || user["state"] as? String == "" || user["rfc"] as? String == "" || user["clabe"] as? String == "" || user["bank"] as? String == "" || user["availableTimes"] as? [String] == nil {
            
            self.isCanCreate = false
            
        }else{
            self.isCanCreate = true
        }
    }
}

// MARK: COLLECTIONVIEW EXTENSION

extension profileYoberMain: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (collectionView == yoberCourseCollection){
            
            return 1 + yoberCoursesArray.count
            
        }else if ( collectionView == yoberServiceCollection ){
            
            return 1 + yoberServicesArray.count
            
        }else if ( collectionView == yoberGalleryCollection ){
            
            return 1 + yoberGalleryArray.count
            
        }else if( collectionView == yoberVoluntaryCollection ){
            
            return 1 + yoberVoluntaryArray.count
            
        }
        
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let i = indexPath.item - 1
        
        if (collectionView == yoberCourseCollection){
            
            if( indexPath.item == 0 ){
                
                let cell = yoberCourseCollection.dequeueReusableCell(withReuseIdentifier: "addCourseCell", for: indexPath) as! profileYoberAddCell
                
                cell.imageBackground.roundCompleteImage()
                
                return cell
                
            }else{
                
                let cell = yoberCourseCollection.dequeueReusableCell(withReuseIdentifier: "courseCell", for: indexPath) as! activityCell
            
                if let imageInformation = yoberCoursesArray[i]["logo"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            cell.activityImage.layer.borderColor = UIColor.black.cgColor
                            cell.activityImage.layer.borderWidth = 0.5
                            cell.activityImage.image = image
                            
                            cell.activityImage.roundCompleteImage()
                            
                        }
                        
                    }
                    
                }else{
                    
                    cell.activityImage.image = nil
                    
                    cell.activityImage.roundCompleteImage()
                    
                }
                
                if let newName = yoberCoursesArray[i]["name"] as? String{
                    cell.activityTitle.text = newName
                }else{
                    cell.activityTitle.text = nil
                }
                
                
                
                return cell
                
            }
            
        }else if ( collectionView == yoberServiceCollection ){
            
            if( indexPath.item == 0 ){
                
                let cell = yoberServiceCollection.dequeueReusableCell(withReuseIdentifier: "addServiceCell", for: indexPath) as! profileYoberAddCell
                
                cell.imageBackground.roundCustomImage(divider: 16)
                
                return cell
                
            }else{
                
                let cell = yoberServiceCollection.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath) as! activityCell
                
                if let imageInformation = yoberServicesArray[i]["logo"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            cell.activityImage.image = image
                            
                            cell.activityImage.roundCustomImage(divider: 16)
                            
                        }
                        
                    }
                    
                }else{
                    
                    cell.activityImage.image = nil
                    
                    cell.activityImage.roundCustomImage(divider: 16)
                    
                }
                
                if let newName = yoberServicesArray[i]["name"] as? String{
                    cell.activityTitle.text = newName
                }else{
                    cell.activityTitle.text = nil
                }
                
                return cell
                
            }
            
        }else if ( collectionView == yoberGalleryCollection ){
            
            if( indexPath.item == 0 ){
                
                let cell = yoberGalleryCollection.dequeueReusableCell(withReuseIdentifier: "addGalleryCell", for: indexPath) as! profileYoberAddCell
                
                cell.imageBackground.roundCustomImage(divider: 16)
                
                return cell
                
            }else{
                
                let cell = yoberGalleryCollection.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! galleryCell
                
                cell.deleteImage.roundCompleteButton()
                
                if let imageInformation = yoberGalleryArray[i]["photoGallery"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            cell.activityImage.image = image
                            
                            cell.activityImage.roundCustomImage(divider: 16)
                            
                            cell.delegate = self
                            
                            cell.imageObject = self.yoberGalleryArray[i]
                            
                        }
                        
                    }
                    
                }
                
                return cell
                
            }
            
        }else if( collectionView == yoberVoluntaryCollection ){
            
            if( indexPath.item == 0 ){
                
                let cell = yoberVoluntaryCollection.dequeueReusableCell(withReuseIdentifier: "addVoluntaryCell", for: indexPath) as! profileYoberAddCell
                
                cell.imageBackground.roundCustomImage(divider: 16)
                
                return cell
                
            }else{
                
                let cell = yoberVoluntaryCollection.dequeueReusableCell(withReuseIdentifier: "voluntaryCell", for: indexPath) as! activityCell
                
                if let imageInformation = yoberVoluntaryArray[i]["logo"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            cell.activityImage.image = image
                            
                            cell.activityImage.roundCustomImage(divider: 16)
                            
                        }
                        
                    }
                    
                }else{
                    
                    cell.activityImage.image = nil
                    
                    cell.activityImage.roundCustomImage(divider: 16)
                    
                }
                
                if let newName = yoberVoluntaryArray[i]["name"] as? String{
                    cell.activityTitle.text = newName
                }else{
                    cell.activityTitle.text = nil
                }
                
                return cell
                
            }
            
        }
            
        let cell = yoberCourseCollection.dequeueReusableCell(withReuseIdentifier: "addCourseCell", for: indexPath) as! profileYoberAddCell
            
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (collectionView == yoberCourseCollection){
            
            return CGSize(width: 80, height: 100)
            
        }else if ( collectionView == yoberServiceCollection ){
            
            return CGSize(width: 100, height: 100)
            
        }else if ( collectionView == yoberGalleryCollection ){
            
            return CGSize(width: 200, height: 120)
            
        }else if( collectionView == yoberVoluntaryCollection ){
            
            return CGSize(width: 100, height: 100)
            
        }
        
        return CGSize(width: 80, height: 100)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let i = indexPath.item - 1
        
        if (collectionView == yoberCourseCollection){
            
            if self.isCanCreate == true {
                
                if (indexPath.item == 0){
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "yoberCreateEditCourse") as? yoberCreateEditCourse
                
                    //viewController?.datesArrayString = self.datesArrayString
                    viewController?.scheduleArray = self.scheduleArray + self.scheduleValuntaryArray
                    
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }else{
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "yoberCreateEditCourse") as? yoberCreateEditCourse
                
                    viewController?.isNew = false
                    viewController?.editableCourse = yoberCoursesArray[i]
                
                    viewController?.scheduleArray = self.scheduleArray + self.scheduleValuntaryArray
                    
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }
            }else{
                self.avisoPopUpView.isHidden = false
            }
            
        }else if ( collectionView == yoberServiceCollection ){
            
            if self.isCanCreate == true {
                
                if (indexPath.item == 0){
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "yoberCreateEditService") as? yoberCreateEditService
                
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }else{
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "yoberCreateEditService") as? yoberCreateEditService
                
                    viewController?.isNew = false
                    viewController?.editableService = yoberServicesArray[i]
                
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }
            }else{
                self.avisoPopUpView.isHidden = false
            }
            
        }else if ( collectionView == yoberGalleryCollection ){
            
            if (indexPath.item == 0){
                
                if( yoberGalleryArray.count < 6 ){
                    
                    self.imageProvider()
                    
                }else{
                    
                    let alert = UIAlertController(title: "ERROR", message: "El límite de imagenes en galería es de 6", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                
            }
            
        }else if( collectionView == yoberVoluntaryCollection ){
            
            if self.isCanCreate == true {
                
                if (indexPath.item == 0){
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "yoberCreateEditVoluntary") as? yoberCreateEditVoluntary
                
                    viewController?.scheduleArray = self.scheduleArray + self.scheduleValuntaryArray
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }else{
                    
                    let viewController = storyboard?.instantiateViewController(withIdentifier: "yoberCreateEditVoluntary") as? yoberCreateEditVoluntary
                
                    viewController?.isNew = false
                    viewController?.editableVoluntary = yoberVoluntaryArray[i]
                    viewController?.scheduleArray = self.scheduleArray + self.scheduleValuntaryArray
                    self.navigationController?.pushViewController(viewController!, animated: true)
                    
                }
            }else{
                self.avisoPopUpView.isHidden = false
            }
        }
    }
}

// MARK: PROTOCOL EXTENSION FUNCTIONS

extension profileYoberMain: deleteGalleryCell{
    
    func deleteGCell(iObject: PFObject) {
        
        iObject.deleteInBackground {  (success: Bool?, error: Error?) in
            
            if let error = error {
                
                print(error.localizedDescription)
                
                let alert = UIAlertController(title: "ERROR", message: "No se ha podido borrar la imagen", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }else if success != nil{
                
                let user = PFUser.current()!
                
                self.updateGallery(yober: user)
                
            }
            
        }
        
    }
    
}

// MARK: IMAGEPICKER FUNCTIONS/EXTENSION

extension profileYoberMain: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

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
        
        picker.dismiss(animated: true, completion: nil)
        
        let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
        loader.mode = MBProgressHUDMode.indeterminate
        loader.backgroundView.color = UIColor.gray
        loader.backgroundView.alpha = 0.5
        loader.label.text = "Guardando Imagen"
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        let imageFile = PFFileObject(name: "galleryPhoto.jpeg", data: imageData!)
        
        let user = PFUser.current()!
        
        let galleryObject = PFObject(className: "Gallery")
        
        galleryObject["photoGallery"] = imageFile
        galleryObject["yober"] = user
        
        galleryObject.saveInBackground {  (success: Bool?, error: Error?) in
            
            loader.hide(animated: true)
            
            if let error = error {
                
                self.sendErrorType(error: error)
                
            }else if success != nil{
                
                self.updateGallery(yober: user)
                
                let alert = UIAlertController(title: "ÉXITO", message: "Imagen guardada", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
                    
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

class Schedule {
    var startSchedule: Date
    var endSchedule: Date
    init(startSchedule: Date, endSchedule: Date ) {
        self.startSchedule = startSchedule
        self.endSchedule = endSchedule
    }
}

