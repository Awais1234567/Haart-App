//
//  RecommendedViewController.swift
//  Haart App
//
//  Created by Stone on 31/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import SDWebImage
import CoreLocation
import SwiftMessages

class RecommendedViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    let db = Firestore.firestore()
    var user = Auth.auth().currentUser
    private var appUsersReference: CollectionReference {
        return db.collection("users")
    }
    var currentUserSnapshot:QueryDocumentSnapshot!
    var shownUserDocument:QueryDocumentSnapshot!
    var personId = ""
    var itemsArr = Array<QueryDocumentSnapshot>()
    var itemsArr1 = Array<QueryDocumentSnapshot>()
    var itemsArr2 = Array<QueryDocumentSnapshot>()
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var searchimageView: UIImageView!
    @IBOutlet weak var searchbar: HaartSearchbar!
    @IBOutlet var dragableImageView : UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
  
    var fcmToken = String()
    var name = String()
    var age = String()
    var distance = String()
    var address = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.searchImageView = searchimageView
        dragableImageView.backgroundColor = .gray
        self.view.addSubview(dragableImageView)
        dragableImageView.isUserInteractionEnabled = true
        dragableImageView.isHidden = true
        self.view.backgroundColor = .red

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }

    func getData() {
        nameLbl.text = name
        ageLbl.text = age
        distanceLbl.text = distance
        addressLbl.text = address
        
        SVProgressHUD.show()
        self.itemsArr.removeAll()
        appUsersReference.getDocuments { (snapshot, error) in
            
            if let documents = snapshot?.documents {
                let user:User = Auth.auth().currentUser!
                // self.itemsArr = documents
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == user.uid) {
                        self.currentUserSnapshot = documents[i]
                        break
                    }
                }
                
                for i in 0..<(documents.count) {
                    if(documents[i].data()["userId"] as! String == self.personId) {
                        self.shownUserDocument = documents[i]
                        self.fcmToken = self.shownUserDocument.data()["fcmToken"] as? String ?? ""
//                        self.nameLbl.text = shownUserDocument.data()["fullName"] as? String ?? ""
//                        //        ageLbl.text = age
//                        self.addressLbl.text = shownUserDocument.data()["address"] as? String ?? ""
//                        var imgUrl = ""
//                        if let imgsArr = shownUserDocument.data()["bioPics"] as? [String] {
//                            if(imgsArr.count > 0) {
//                                imgUrl = imgsArr[0]
//                            }
//                        }
//                        self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
//                        self.imgView.sd_setImage(with: URL(string:imgUrl), placeholderImage: nil)
//
//                        let currentUserLocation = CLLocation.init(latitude: self.currentUserSnapshot?.data()["lat"] as? CLLocationDegrees ?? 0, longitude: self.currentUserSnapshot?.data()["lng"] as? CLLocationDegrees ?? 0)
//                       let shownUserLocation = CLLocation.init(latitude: shownUserDocument.data()["lat"] as? CLLocationDegrees ?? 0, longitude: shownUserDocument.data()["lng"] as? CLLocationDegrees ?? 0)
//
//                        let distance = CGFloat((currentUserLocation.distance(from: shownUserLocation)) / 1600)
//                        let text = "\(String(format: "%.2f", distance)) mi away"
//                        self.distanceLbl.text = text
//
//                        if let dob = shownUserDocument.data()["dob"] as? String {
//                            if(dob.count > 0) {
//                                self.ageLbl.text = dob.getAgeFromDOB().0.string
//                            }
//                        }
//                        else {
//                            self.ageLbl.text = ""
//                        }
//
                    }
                    else if(documents[i].data()["userId"] as! String == user.uid) {
                        
                    }
                    else if(((documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(user.uid))) {
                        
                    }
                    else if((self.currentUserSnapshot.data()["blocked"] as? Array<String> ?? [String]()).contains(documents[i].data()["userId"] as! String)) {
                        
                    }
                    else if ((self.currentUserSnapshot.data()["followed"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String)) {
                        self.itemsArr.append(documents[i])
                    }
                    else if((self.currentUserSnapshot.data()["followedBy"] as? Array<String> ?? Array<String>()).contains(documents[i].data()["userId"] as! String)) {
                        self.itemsArr.append(documents[i])
                    }
                   
                }
                
                
                let tuple = self.split()
                self.itemsArr1 = tuple.right
                self.itemsArr2 = tuple.left
                self.collectionView1.reloadData()
                self.collectionView2.reloadData()
            }
            else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "")
            }
            SVProgressHUD.dismiss()
        }
    }
    func split() -> (left: [QueryDocumentSnapshot], right: [QueryDocumentSnapshot]) { // divide array in two arrays
        let ct = itemsArr.count
        let half = ct / 2
        let leftSplit = itemsArr[0 ..< half]
        let rightSplit = itemsArr[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionView == collectionView1 ? itemsArr1.count : itemsArr2.count
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : RecommendedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath as IndexPath) as! RecommendedCell
        if(collectionView == collectionView1) {
            
            if let imgsArr = (itemsArr1[indexPath.row].data()["bioPics"] as? [String]) {
                if(imgsArr.count > 0) {
                    cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                    cell.imgView.sd_setImage(with: URL(string:imgsArr[0]), placeholderImage: nil)
                }
            }
            cell.imgView.accessibilityLabel = itemsArr1[indexPath.row].data()["userId"] as? String ?? ""
            cell.imgView.accessibilityHint = itemsArr1[indexPath.row].data()["fullName"] as? String ?? ""
            cell.userNameLbl.text = itemsArr1[indexPath.row].data()["userName"] as? String ?? ""
        }
        else {
            if let imgsArr = (itemsArr2[indexPath.row].data()["bioPics"] as? [String]) {
                if(imgsArr.count > 0) {
                    cell.imgView2.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                    cell.imgView2.sd_setImage(with: URL(string:imgsArr[0]), placeholderImage: nil)
                    
                }
            }
            cell.imgView2.accessibilityLabel = itemsArr2[indexPath.row].data()["userId"] as? String ?? ""
            cell.imgView2.accessibilityHint = itemsArr2[indexPath.row].data()["fullName"] as? String ?? ""
            cell.userNameLbl2.text = itemsArr2[indexPath.row].data()["userName"] as? String ?? ""
        }
        cell.addLongPressGesture()
        return cell
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func longPressGesture(sender: UIGestureRecognizer) {// this method is called from sticker cell class when sticker is longpressed (MyCollectionCell)
        let gestureView = sender.view
        //(to add the sticker by drag drop)
        if sender.state == .began { // setting dragableImageView on selected emoji
          
            self.dragableImageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.dragableImageView.sd_setImage(with:gestureView?.sd_imageURL , placeholderImage: nil)
           
            let frame = sender.view?.superview?.convert((sender.view?.frame)!, to: self.view)
          //  dragableImageView.image = //emojisControl.itemsArr[(sender.view?.tag)!]
            dragableImageView.frame = CGRect(x:(frame?.origin.x)! - 5.0, y:(frame?.origin.y)! - 5.0, width:(frame?.size.width)! + 10.0,  height:(frame?.size.height)! + 10.0)
            dragableImageView.layer.cornerRadius = dragableImageView.frame.size.height / 2
            dragableImageView.isHidden = false
            UIView.animate(withDuration: 0.1, animations: {
                self.dragableImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
        }
        
        if(sender.state == .changed) { // setting dragableImageView on draging position
            let center = sender.location(in: self.view)
            dragableImageView.center = center
        }
        
        if (sender.state == .ended) { // setting sticker in editor view
            UIView.animate(withDuration: 0.1, animations: {
               self.dragableImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }) { (abc) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.dragableImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)

                }, completion: { (abc) in
                    self.dragableImageView.isHidden = true
                    self.dragableImageView.center = CGPoint(x: 0,y: 0)
                    self.dragableImageView.transform = CGAffineTransform.identity
                    self.suggest(suggestionUserId: gestureView?.accessibilityLabel ?? "", suggestionfullName: gestureView?.accessibilityHint ?? "")
                })
            }
        }
    }
    
    func suggest(suggestionUserId:String, suggestionfullName:String) {
        SVProgressHUD.show()
        let ref = db.collection("users").whereField("userId", isEqualTo: personId)
        ref.getDocuments { (snapshot, error) in
            let document = snapshot?.documents[0]
            var suggestedArr = document?.data()["suggested"] as? [String] ?? Array<String>()
            if(!suggestedArr.contains(suggestionUserId)) {
                suggestedArr.append(suggestionUserId)
            }
            document?.reference.updateData(["suggested":suggestedArr], completion: { (error) in
                SVProgressHUD.dismiss()
                PushNotificationSender().sendPushNotification(to: self.fcmToken, title: "Recommendation:", body: "\(self.currentUserSnapshot.data()["fullName"] as! String) \("recommended you ") \(suggestionfullName)", type:"Recommendation", id:self.user?.uid ?? "")
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                    UIApplication.showMessageWith("Recommended!")
                }
            })
        }
    }
    @IBAction func superLikeBtnPressed(_ sender: Any) {
        
        var unreadSuperLikesCount = self.shownUserDocument?.data()["unreadSuperLikesCount"] as? Int ?? 0
        //  let unreadSuperLikesCount = self.shownUserDocument?.data()["unreadSuperLikesCount"] as? Int ?? 0
        var unreadMatchesCount = self.shownUserDocument?.data()["unreadMatchesCount"] as? Int ?? 0
        var currentUserUnreadMatchesCount = self.currentUserSnapshot?.data()["unreadMatchesCount"] as? Int ?? 0
        
        
        if let lastSuperLikedTimeStampSeconds = self.currentUserSnapshot?["lastSuperLikedTime"] as? Int64 {
            let currentTimeInSeconds = Timestamp.init().seconds
            let dif = currentTimeInSeconds - lastSuperLikedTimeStampSeconds
            if(dif < 150) {
                UIApplication.showMessageWith("There should be difference of atleast 2 min and 30 seconds between two Superlikes")
                return
            }
        }
        
        SVProgressHUD.show()
        let personSuperLikedArr = self.shownUserDocument?.data()["superLiked"] as? [String] ?? Array<String>()
        let myFullName = self.currentUserSnapshot?.data()["fullName"] as! String
        let personDeviceToken = self.shownUserDocument?.data()["fcmToken"] as? String ?? ""
        let personName = self.shownUserDocument?.data()["fullName"] as! String
        let personId = self.shownUserDocument?.data()["userId"] as! String
        var superLikedArr = self.currentUserSnapshot?.data()["superLiked"] as? [String] ?? Array<String>()
        var likedArr = self.currentUserSnapshot?.data()["liked"] as? [String] ?? Array<String>()
        if(likedArr.contains(personId)) {
            if let index = likedArr.firstIndex(of: personId) {
                likedArr.remove(at: index)
            }
        }
        if(!superLikedArr.contains(personId)) {
            superLikedArr.append(personId)
            unreadSuperLikesCount = unreadSuperLikesCount + 1
        }
        if(personSuperLikedArr.contains(self.user!.uid)) {//match
            unreadMatchesCount = unreadMatchesCount + 1
            currentUserUnreadMatchesCount = currentUserUnreadMatchesCount + 1
        }
        self.currentUserSnapshot?.reference.updateData(["superLiked":superLikedArr, "liked": likedArr, "lastSuperLikedTime":Timestamp.init().seconds, "unreadMatchesCount":currentUserUnreadMatchesCount], completion: { (error) in
            
            if let e = error {
                SVProgressHUD.dismiss()
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                
                if(personSuperLikedArr.contains(self.user!.uid)){
                    PushNotificationSender().sendPushNotification(to: personDeviceToken, title: "New Match:", body: "It's a Supermatch with \(myFullName)", type:"", id:"")
                    PushNotificationSender().sendLocalNotification(title: "New Match:", body: "It's a Match with \(personName)", type:"New Match", id:self.user?.uid ?? "")
                }
                else {
                    PushNotificationSender().sendPushNotification(to: personDeviceToken, title: "Super Like:", body: "\(myFullName) Super Liked Your Profile", type:"Super Like", id:self.user?.uid ?? "")
                }
                self.shownUserDocument?.reference.updateData(["unreadSuperLikesCount":unreadSuperLikesCount, "unreadMatchesCount":unreadMatchesCount], completion: { (error) in
                    SVProgressHUD.dismiss()
                    let view = MessageView.viewFromNib(layout: .centeredView)
                    view.configureTheme(.warning)
                    view.configureDropShadow()
                    let iconText = "❤️"
                    view.configureContent(title: "", body: "Super Liked", iconText: iconText)
                    SwiftMessages.show(view: view)
                    view.button?.removeFromSuperview()
                })
                
            }
        })
    }
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        SVProgressHUD.show()
        var unreadLikesCount = self.shownUserDocument?.data()["unreadLikesCount"] as? Int ?? 0
      //  let unreadSuperLikesCount = self.shownUserDocument?.data()["unreadSuperLikesCount"] as? Int ?? 0
        var unreadMatchesCount = self.shownUserDocument?.data()["unreadMatchesCount"] as? Int ?? 0
        var currentUserUnreadMatchesCount = self.currentUserSnapshot?.data()["unreadMatchesCount"] as? Int ?? 0
        var likedArr = self.currentUserSnapshot?.data()["liked"] as? [String] ?? Array<String>()
        let personLikedArr = self.shownUserDocument.data()["liked"] as? [String] ?? Array<String>()
        let myFullName = self.currentUserSnapshot?.data()["fullName"] as! String
        let personName = self.shownUserDocument.data()["fullName"] as! String
        let personDeviceToken = self.shownUserDocument.data()["fcmToken"] as? String ?? ""
        let personId = self.shownUserDocument.data()["userId"] as! String
        if(!likedArr.contains(personId)) {
            likedArr.append(personId)
            unreadLikesCount = unreadLikesCount + 1
        }
        
        if(personLikedArr.contains(self.user!.uid)) {// match
            unreadMatchesCount = unreadMatchesCount + 1
            currentUserUnreadMatchesCount = currentUserUnreadMatchesCount + 1
        }
        
        var superLikedArr = self.currentUserSnapshot?.data()["superLiked"] as? [String] ?? Array<String>()
        if let index = superLikedArr.firstIndex(of: personId) {
            superLikedArr.remove(at: index)
        }
        self.currentUserSnapshot?.reference.updateData(["liked":likedArr,"superLiked":superLikedArr, "unreadMatchesCount":currentUserUnreadMatchesCount], completion: { (error) in
            
            if let e = error {
                SVProgressHUD.dismiss()
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                if(personLikedArr.contains(self.user!.uid)) {
                    PushNotificationSender().sendPushNotification(to: personDeviceToken, title: "New Match:", body: "It's a Match with \(myFullName)", type:"New Match", id:self.user?.uid ?? "")
                    PushNotificationSender().sendLocalNotification(title: "New Match:", body: "It's a Match with \(personName)", type:"New Match", id:self.user?.uid ?? "")
                }
                else {
                    PushNotificationSender().sendPushNotification(to: personDeviceToken, title: "Like:", body: "\(myFullName) Liked Your Profile", type:"Like", id:self.user?.uid ?? "")
                }
                self.shownUserDocument.reference.updateData(["unreadLikesCount":unreadLikesCount, "unreadMatchesCount":unreadMatchesCount], completion: { (error) in
                    SVProgressHUD.dismiss()
                    
                    let view = MessageView.viewFromNib(layout: .centeredView)
                    view.configureTheme(.success)
                    view.configureDropShadow()
                    let iconText = "❤️"
                    view.configureContent(title: "", body: "Liked", iconText: iconText)
                    SwiftMessages.show(view: view)
                    view.button?.removeFromSuperview()
                })
            }
        })
        
    }
    @IBAction func dislikeBtnPressed(_ sender: Any) {
    }
    
    @IBAction func friendsBtnPressed(_ sender: Any) {
        selectTabAtIndex(index: 1)
    }
    @IBAction func mapBtnPressed(_ sender: Any) {
        selectTabAtIndex(index: 3)
    }
    @IBAction func homeBtnPressed(_ sender: Any) {
         selectTabAtIndex(index: 2)
    }
    
    func selectTabAtIndex(index:Int) {
        if let rootVC = UIApplication.rootViewController as? HaartTabViewCotroller {
            rootVC.selectedIndex = index
            if(UIApplication.visibleViewController.navigationController == nil) {
                UIApplication.visibleViewController.dismiss(animated: true) {
                    
                }
            }
        }
    }
}
