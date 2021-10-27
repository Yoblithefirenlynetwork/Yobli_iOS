//
//  exploreYoberProfile.swift
//  Yobli
//
//  Created by Humberto on 7/31/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import MBProgressHUD

class exploreYoberProfile: UIViewController, CourseRowDelegate, ServiceRowDelegate, GalleryRowDelegate{
    
    // MARK: OUTLETS
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var yoberPhoto: UIImageView!
    
    @IBOutlet weak var yoberUsername: UILabel!
    
    @IBOutlet weak var yoberDescription: UILabel!
    
    @IBOutlet weak var yoberDetails: UILabel!
    
    @IBOutlet weak var yoberGrade: UIImageView!
    
    @IBOutlet weak var favoriteIcon: UIButton!
    
    @IBOutlet weak var collectionTableView: UITableView!
    
    @IBOutlet weak var bottomViewHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var reportYoberButton: UIButton!
    @IBOutlet weak var blockYoberButton: UIButton!
    @IBOutlet weak var contactYoberButton: UIButton!
    
    
    
    //MARK: VARs/LETs
    
    var yoberId = ""
    var yoberName = ""
    
    var categories = [String]()
    
    var yoberCoursesArray = [PFObject]()
    
    var yoberServicesArray = [PFObject]()
    
    var yoberGalleryArray = [PFObject]()
    var yoberGalleryPosition = 0
    var newImageView = UIImageView()
    
    var yoberReady = PFUser()
    
    var contact = [String:String]()
    var conversationUserSideId : String?
    var conversationYoberSideId: String?
    
    let userChatController = ChatMainController()
    
    var AppearOnce = true
    
    // MARK: MAIN FUNCTION VIEWDIDLOAD
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Fill view
        self.showHUD(progressLabel: "Cargando Perfil...")
        self.updateView()
        
        collectionTableView.dataSource = self
        collectionTableView.delegate = self
        
        yoberPhoto.roundCompleteImageColor()
        
        self.dismissWithSwipe()
        
        let currentUser = PFUser.current()
        
        if currentUser?.objectId == self.yoberId {
            self.favoriteIcon.isHidden = true
            self.contactYoberButton.isHidden = true
            self.reportYoberButton.isHidden = true
            self.blockYoberButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if PFUser.current() == nil {
         
            self.sendAlert()
            
        }
        
        if(AppearOnce != true){
        
            self.showHUD(progressLabel: "Actualizando...")
            self.updateView()
            
        }
        
    }
    
    // MARK: BUTTON FUNCTIONS
    
    @IBAction func reportYoberButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ExploreReportViewController") as? ExploreReportViewController
        
        
        viewController?.objectIdYober = self.yoberReady.objectId ?? ""
        viewController?.isReport = true
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func blockYoberButton(_ sender: UIButton) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ExploreReportViewController") as? ExploreReportViewController
        
        viewController?.objectIdYober = self.yoberReady.objectId ?? ""
        viewController?.isBlock = true
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
    @IBAction func returnView(_ sender: Any) {
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func yoberAgenda(_ sender: Any) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreAgenda") as? exploreAgenda
        
        viewController?.yoberId = yoberId

        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    @IBAction func contactYober(_ sender: Any) {
        
        if(conversationUserSideId == nil && conversationYoberSideId == nil){
            
            self.createNewConversation()
                
        }else{
                
            self.goToExistingConversation(result: contact)
                
        }
        
    }
    
    @IBAction func makeFavorite(_ sender: Any) {
        
        let pointer = PFObject(withoutDataWithClassName: "User", objectId: yoberReady.objectId)
        
        if( self.favoriteIcon.image(for: .normal)!.isEqual(UIImage(named: "heartNoSelect") ) ){
            
            self.favoriteIcon.setImage(UIImage(named: "heartSelect"), for: .normal)
            
            let user = PFUser.current()!
            
            user.addUniqueObject(pointer, forKey:"favoriteYobers")
            
            user.saveInBackground()
            
        }else{
            
            self.favoriteIcon.setImage(UIImage(named: "heartNoSelect"), for: .normal)
            
            let user = PFUser.current()!
            
            user.remove(pointer, forKey:"favoriteYobers")
            
            user.saveInBackground()
            
        }
        
        
    }
    
    @IBAction func share(_ sender: UIButton) {
        
//        let urlCustom = URL(string: "https://yobli.brounieapps.com/User/\(yoberId)" )
//
//        guard let customURL = urlCustom else {
//
//            print("Couldnt create url")
//
//            return
//
//        }
//
//        let av = UIActivityViewController(activityItems: [customURL], applicationActivities: nil)
//
//        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
        let someText:String = "Yobli"
        let objectsToShare:URL = URL(string: "https://parse.yobli.com/User/\(yoberId)")!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]

        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    
    // MARK: UPDATE VIEW
    
    func updateView(){
        
        let queryYober : PFQuery = PFUser.query()!
        
        queryYober.whereKey("objectId", equalTo:yoberId)
        
        queryYober.getFirstObjectInBackground { (object: PFObject?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.sendErrorTypeAndDismiss(error: error)
            } else if let object = object {
                // The find succeeded.
                //userPhotoYober
                if let imageInformation = object["userPhoto"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            self.yoberPhoto.image = image
                        }
                        
                    }
                
                }
                
                if let newName = object["name"] as? String{
                    self.yoberUsername.text = newName
                    self.yoberName = newName
                    
                    self.contactUser()
                    self.getIfContact()
                    
                }else{
                    self.yoberUsername.text = nil
                }
                
                if let newDescription = object["yoberDescription"] as? String{
                    self.yoberDescription.text = newDescription
                }else{
                    self.yoberDescription.text = nil
                }
                
                self.yoberGrade.gradeResults(id: self.yoberId)
                
                if let newCategory = object["category"] as? String{
                    
                    if let newPriceRange = object["priceRange"] as? String{
                        
                        if let newState = object["state"] as? String{
                            
                            if let newCity = object["city"] as? String{
                                
                                if let newZone = object["zone"] as? String{
                                    
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
                    
                }else if let newPriceRange = object["priceRange"] as? String{
                    
                    if let newState = object["state"] as? String{
                        
                        if let newCity = object["city"] as? String{
                            
                            if let newZone = object["zone"] as? String{
                                
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
                    
                }else if let newState = object["state"] as? String{
                    
                    if let newCity = object["city"] as? String{
                        
                        if let newZone = object["zone"] as? String{
                            
                            self.yoberDetails.text = newState + ", " + newCity + ", " + newZone
                            
                        }
                        else{
                            
                            self.yoberDetails.text = newState + ", " + newCity
                            
                        }
                        
                    }else{
                        
                        self.yoberDetails.text = newState
                        
                    }
                    
                    
                }else{
                    
                    self.yoberDetails.text = nil
                    
                }
                
                self.yoberReady = object as! PFUser
                
                self.queries(yober: object)
                
            }
            
            let user = PFUser.current()!
            
            if let newYoberArray = user["favoriteYobers"] as? [PFObject]{
                
                let pointer = PFObject(withoutDataWithClassName: "User", objectId: self.yoberReady.objectId)
                
                if( newYoberArray.contains(pointer) ){
                    
                    self.favoriteIcon.setImage(UIImage(named: "heartSelect"), for: .normal)
                    
                }
                else{
                    
                    self.favoriteIcon.setImage(UIImage(named: "heartNoSelect"), for: .normal)
                    
                }
            }else{
                
                self.favoriteIcon.setImage(UIImage(named: "heartNoSelect"), for: .normal)
                
            }
            
        }
        
    }
    
    //MARK: QUERIE TO GET COURSES, SERVICES, GALLERY
    
    func queries(yober: PFObject){
        
        //Queries to get from the Database
        
        let currentDate = Date()
        
        let queryCourse = PFQuery(className:"Course")
        queryCourse.whereKey("yober", equalTo: yober)
        queryCourse.whereKey("active", equalTo: true)
        queryCourse.whereKey("date", greaterThan: currentDate)
        
        queryCourse.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.yoberCoursesArray = object
                
            }
            
            self.collectionTableView.reloadData()
            
        }
        
        ///Query to get the Categories on the Database
        
        let queryService = PFQuery(className:"Service")
        queryService.whereKey("yober", equalTo: yober)
        queryService.whereKey("active", equalTo: true)
        //queryService.whereKey("private", equalTo: false)
        
        queryService.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.yoberServicesArray = object
                
            }
            
            self.collectionTableView.reloadData()
            
        }
        
        
        //Query to get the Users that are Yobers
        
        let queryGallery = PFQuery(className: "Gallery")
        
        queryGallery.whereKey("yober" , equalTo: yober)
        
        queryGallery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let object = objects {
                // The find succeeded.
                self.yoberGalleryArray = object
                
                
            }
            
            self.collectionTableView.reloadData()
            
        }
        
    }
    
    //MARK: FUNCTION CONTACTS
    
    func contactUser(){
        
        userChatController.searchUser(id: yoberId)
        
        userChatController.completion = { [weak self] result in
                
            self?.contact = result
                
        }
        
    }
    
    func getIfContact(){
        
        guard let myUserId = PFUser.current()!.objectId else {
            return
        }
        
        userChatController.searchConversationIdInSender(receiverId: yoberId, senderId: myUserId)
        userChatController.searchConversationIdInReceiver(receiverId: yoberId, senderId: myUserId)
        
        userChatController.completionId = { [weak self] result in
            
            self?.conversationUserSideId = result
            
        }
        
        userChatController.completionId2 = { [weak self] result2 in
         
            self?.conversationYoberSideId = result2
            
        }
        
        AppearOnce = false
        self.dismissHUD(isAnimated: true)
        
    }
    
    func createNewConversation(){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberName, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: true)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func goToExistingConversation(result: [String:String]){
        let object = PFUser.current()
        guard let idUser = PFUser.current()!.objectId, let userName = object?["name"] as? String else{
            return
        }
        
        let viewController = supportView.generateBarContactYober(otherUserId: yoberId, otherUserName: yoberName, userId: idUser, userName: userName, senderSideId: conversationUserSideId, receiverSideId: conversationYoberSideId, isNew: false)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

// MARK: TABLEVIEW DELEGATE

extension exploreYoberProfile: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor.white
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        categories = []
        
        if(yoberCoursesArray.count > 0){
            categories.append("Cursos")
        }
        if(yoberServicesArray.count > 0){
            categories.append("Servicios")
        }
        if(yoberGalleryArray.count > 0){
            categories.append("Galeria")
        }
        
        switch categories.count {
        case 0:
            self.bottomViewHeightConstrain.constant = 0
            mainView.layoutIfNeeded()
            break
        case 1:
            self.bottomViewHeightConstrain.constant = 190
            mainView.layoutIfNeeded()
            break
        case 2:
            self.bottomViewHeightConstrain.constant = 370
            mainView.layoutIfNeeded()
            break
        case 3:
            self.bottomViewHeightConstrain.constant = 550
            mainView.layoutIfNeeded()
            break
        default:
            break
        }
        
        
        return categories.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 180
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.categories[indexPath.section] {
        case "Servicios":
            let cell = collectionTableView.dequeueReusableCell(withIdentifier: "CategoryYoberRow") as! CategoryYoberRow
            
            cell.yoberServicesArray = yoberServicesArray
            cell.actualSection = categories[indexPath.section]
            cell.yoberSection.text = categories[indexPath.section]
            cell.delegate2 = self
            cell.yoberCollection.reloadData()
            
            return cell
            
        case "Galeria":
            
            let cell = collectionTableView.dequeueReusableCell(withIdentifier: "CategoryYoberRow") as! CategoryYoberRow
            
            cell.yoberGalleryArray = yoberGalleryArray
            cell.actualSection = categories[indexPath.section]
            cell.yoberSection.text = categories[indexPath.section]
            cell.delegate3 = self
            cell.yoberCollection.reloadData()
            
            return cell
            
        default:
            
            let cell = collectionTableView.dequeueReusableCell(withIdentifier: "CategoryYoberRow") as! CategoryYoberRow
            
            cell.yoberCoursesArray = yoberCoursesArray
            cell.actualSection = categories[indexPath.section]
            cell.yoberSection.text = categories[indexPath.section]
            cell.delegate1 = self
            cell.yoberCollection.reloadData()
            
            return cell
            
        }
        
    }
    
    func cellCourse(position: Int){
    //code for navigation
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreCourse") as? exploreCourse
        
        guard let id = yoberCoursesArray[position].objectId else{
            return
        }
        
        let couse = self.yoberCoursesArray[position]
        let yober = couse["yober"] as? PFObject
        let yoberId = yober?.objectId
        
        viewController?.yoberObjectId = yoberId ?? ""
        
        viewController?.courseId = id
        
        self.navigationController?.pushViewController(viewController!, animated: true)

        
    }
    
    func cellService(position: Int){
    //code for navigation
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "exploreService") as? exploreService
        
        guard let id = yoberServicesArray[position].objectId else{
            return
        }
        
        let service = self.yoberServicesArray[position]
        let yober = service["yober"] as? PFObject
        let yoberId = yober?.objectId
        
        viewController?.yoberObjectId = yoberId ?? ""
        viewController?.serviceId = id
        
        
        self.navigationController?.pushViewController(viewController!, animated: true)

        
    }
    
    func cellGallery(position: Int){
    //code for navigation
        
        yoberGalleryPosition = position
        
        self.restartGestures()
        
        if let imageInformation = yoberGalleryArray[yoberGalleryPosition]["photoGallery"] as? PFFileObject{
        
            imageInformation.getDataInBackground{
                
                (imageData: Data?, error: Error?) in
                if let error = error{
                    print(error.localizedDescription)
                }else if let imageData = imageData{
                    
                    let image = UIImage(data: imageData)
                    
                    self.newImageView.image = image
                    self.newImageView.frame = UIScreen.main.bounds
                    self.newImageView.backgroundColor = .black
                    self.newImageView.contentMode = .scaleAspectFit
                    self.newImageView.isUserInteractionEnabled = true
                    
                    //ADD GESTURES
                    
                    self.newImageView.gestureRecognizers = []
                    
                    //TAP GESTURE
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
                    
                    self.newImageView.addGestureRecognizer(tap)
                    
                    //SWIPE GESTURE
                    
                    if(self.yoberGalleryPosition < self.yoberGalleryArray.count - 1){
                        //Puede hacer swipe hacia la izquierda
                        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction) )
                        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
                        self.newImageView.addGestureRecognizer(swipeLeft)
                    }
                    
                    if(self.yoberGalleryPosition > 0 ){
                        //Puede hacer swipe hacia la derecha
                        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction) )
                        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                        self.newImageView.addGestureRecognizer(swipeRight)
                    }
                    
                    //ADD SUBVIEW
                    
                    self.view.addSubview(self.newImageView)
                    self.navigationController?.isNavigationBarHidden = true
                    self.tabBarController?.tabBar.isHidden = true
                    
                }
                
            }
        
        }
        
    }
    
    //MARK: SWIPE AND TAP FUNCTIONS GALLERY

    @objc func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        
        self.dismissWithSwipe()
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @objc func swipeAction(sender: UIGestureRecognizer){
        
        if let swipeGesture = sender as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {

            case UISwipeGestureRecognizer.Direction.left:
                
                self.yoberGalleryPosition = self.yoberGalleryPosition + 1

                if let imageInformation = yoberGalleryArray[yoberGalleryPosition]["photoGallery"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            self.newImageView.image = image
                            
                            //ADD GESTURES
                            
                            self.newImageView.gestureRecognizers = []
                            
                            //TAP GESTURE
                            
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
                            
                            self.newImageView.addGestureRecognizer(tap)
                            
                            //SWIPE GESTURE
                            
                            if(self.yoberGalleryPosition < self.yoberGalleryArray.count - 1){
                                //Puede hacer swipe hacia la izquierda
                                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction) )
                                swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
                                self.newImageView.addGestureRecognizer(swipeLeft)
                            }
                            
                            if(self.yoberGalleryPosition > 0 ){
                                //Puede hacer swipe hacia la derecha
                                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction) )
                                swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                                self.newImageView.addGestureRecognizer(swipeRight)
                            }
                            
                        }
                        
                    }
                
                }
                
            case UISwipeGestureRecognizer.Direction.right:

                self.yoberGalleryPosition = self.yoberGalleryPosition - 1
                
                if let imageInformation = yoberGalleryArray[yoberGalleryPosition]["photoGallery"] as? PFFileObject{
                
                    imageInformation.getDataInBackground{
                        
                        (imageData: Data?, error: Error?) in
                        if let error = error{
                            print(error.localizedDescription)
                        }else if let imageData = imageData{
                            
                            let image = UIImage(data: imageData)
                            
                            self.newImageView.image = image
                            
                            //ADD GESTURES
                            
                            self.newImageView.gestureRecognizers = []
                            
                            //TAP GESTURE
                            
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
                            
                            self.newImageView.addGestureRecognizer(tap)
                            
                            //SWIPE GESTURE
                            
                            if(self.yoberGalleryPosition < self.yoberGalleryArray.count - 1){
                                //Puede hacer swipe hacia la izquierda
                                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction) )
                                swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
                                self.newImageView.addGestureRecognizer(swipeLeft)
                            }
                            
                            if(self.yoberGalleryPosition > 0 ){
                                //Puede hacer swipe hacia la derecha
                                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction) )
                                swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                                self.newImageView.addGestureRecognizer(swipeRight)
                            }
                            
                        }
                        
                    }
                
                }
                
            default:
                break
            }
            
        }
    }
    
}

extension exploreYoberProfile{
    
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
