//
//  HomeCollectionViewCell.swift
//  Haart App
//
//  Created by Stone on 25/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage
import Firebase
import FirebaseFirestore
import CoreLocation
import FirebaseAuth
import SVProgressHUD

class HomeCollectionViewCell: UICollectionViewCell {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var currentUserDocument:QueryDocumentSnapshot?
    var userDocument:QueryDocumentSnapshot?
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    var unreadLikesCount:Int = 0
    var unreadSuperLikesCount:Int = 0
    var unreadMatchesCount:Int = 0
    var currentUserUnreadMatchesCount:Int = 0
    var indexPath:IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        //imgView.roundTop(value:10)
    }

    func setData(userDocument:QueryDocumentSnapshot) {
        self.userDocument = userDocument
        unreadLikesCount = self.userDocument?.data()["unreadLikesCount"] as? Int ?? 0
        unreadSuperLikesCount = self.userDocument?.data()["unreadSuperLikesCount"] as? Int ?? 0
        unreadMatchesCount = self.userDocument?.data()["unreadMatchesCount"] as? Int ?? 0
        currentUserUnreadMatchesCount = self.currentUserDocument?.data()["unreadMatchesCount"] as? Int ?? 0

        //calculate distance
        let otherUserLocation = CLLocation.init(latitude: userDocument.data()["lat"] as? CLLocationDegrees ?? 0, longitude: userDocument.data()["lng"] as? CLLocationDegrees ?? 0)
        let currentUserLocation = CLLocation.init(latitude: currentUserDocument?.data()["lat"] as? CLLocationDegrees ?? 0, longitude: currentUserDocument?.data()["lng"] as? CLLocationDegrees ?? 0)
        let distance = CGFloat((currentUserLocation.distance(from: otherUserLocation)) / 1600)
        let text = "\(String(format: "%.2f", distance)) mi away"
        distanceLbl.text = text
        
        if let imgsArr = (self.userDocument?.data()["bioPics"] as? [String]) {
            if(imgsArr.count > 0) {
                self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                self.imgView.sd_setImage(with: URL(string:imgsArr[0]), placeholderImage: nil)
            }
        }
        else {
            self.imgView.image = nil
        }
        nameLbl.text = userDocument.data()["fullName"] as? String
        descLbl.text = userDocument.data()["bio"] as? String
        addressLbl.text = userDocument.data()["address"] as? String ?? ""
        if let dob = userDocument.data()["dob"] as? String {
            if(dob.count > 0) {
                ageLbl.text = dob.getAgeFromDOB().0.string
            }
        }
        else {
            self.ageLbl.text = ""
        }
    }
    
    @IBAction func moreBtnPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "OthersBioViewController") as! OthersBioViewController
        vc.userId = self.userDocument?.data()["userId"] as? String ?? ""
        vc.currentUserDocument = currentUserDocument
         UIApplication.visibleViewController.present(HaartNavBarController.init(rootViewController: vc), animated: true, completion: nil)
        //UIApplication.visibleViewController.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func feedBrnPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FeedControl")
        UIApplication.visibleViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ignoreBtnPressed(_ sender: Any) {
        SVProgressHUD.show()
        
//        var disLikedArr = self.currentUserDocument?.data()["disLiked"] as? [String] ?? Array<String>()
//        let personId = self.userDocument?.data()["userId"] as! String
//        if(!disLikedArr.contains(personId)) {
//            disLikedArr.append(personId)
//        }
        
        var likedArr = self.currentUserDocument?.data()["liked"] as? [String] ?? Array<String>()
        let personId = self.userDocument?.data()["userId"] as! String
        if let index = likedArr.firstIndex(of: personId) {
            likedArr.remove(at: index)
        }
        
        var superLikedArr = self.currentUserDocument?.data()["superLiked"] as? [String] ?? Array<String>()
        if let index = superLikedArr.firstIndex(of: personId) {
            superLikedArr.remove(at: index)
        }
        
        self.currentUserDocument?.reference.updateData(["liked":likedArr, "superLiked":superLikedArr], completion: { (error) in
            
            if let e = error {
                SVProgressHUD.dismiss()
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                
                SVProgressHUD.dismiss()
                if let vc = UIApplication.visibleViewController as? HomeViewController {
                    vc.itemsArr.remove(at: self.indexPath.row)
                    vc.homeCollectionView.reloadData()
                }
                
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.error)
                view.configureDropShadow()
               // let iconText = "❤️"
                view.configureContent(title: "", body: "Disliked", iconText: "")
                SwiftMessages.show(view: view)
                view.button?.removeFromSuperview()
                
                
            }
        })

        
    }
    @IBAction func suggestBtnPressed(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RecommendedViewController") as! RecommendedViewController
        vc.personId = self.userDocument?.data()["userId"] as? String ?? ""
        vc.name = nameLbl.text ?? ""
        vc.age = ageLbl.text ?? ""
        vc.distance = distanceLbl.text ?? ""
        vc.address = addressLbl.text ?? ""
        
        UIApplication.visibleViewController.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
            var likedArr = self.currentUserDocument?.data()["liked"] as? [String] ?? Array<String>()
            let personLikedArr = self.userDocument?.data()["liked"] as? [String] ?? Array<String>()
            let myFullName = self.currentUserDocument?.data()["fullName"] as! String
            let personName = self.userDocument?.data()["fullName"] as! String
            let personDeviceToken = self.userDocument?.data()["fcmToken"] as? String ?? ""
            let personId = self.userDocument?.data()["userId"] as! String
            if(!likedArr.contains(personId)) {
                likedArr.append(personId)
                unreadLikesCount = unreadLikesCount + 1
            }
        
            if(personLikedArr.contains(self.user!.uid)) {// match
                unreadMatchesCount = unreadMatchesCount + 1
                currentUserUnreadMatchesCount = currentUserUnreadMatchesCount + 1
            }
        
        
            var superLikedArr = self.currentUserDocument?.data()["superLiked"] as? [String] ?? Array<String>()
            if let index = superLikedArr.firstIndex(of: personId) {
                superLikedArr.remove(at: index)
            }
        self.currentUserDocument?.reference.updateData(["liked":likedArr,"superLiked":superLikedArr, "unreadMatchesCount":currentUserUnreadMatchesCount], completion: { (error) in
            
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
                    self.userDocument?.reference.updateData(["unreadLikesCount":self.unreadLikesCount, "unreadMatchesCount":self.unreadMatchesCount], completion: { (error) in
                        SVProgressHUD.dismiss()
                        if let vc = UIApplication.visibleViewController as? HomeViewController {
                            vc.itemsArr.remove(at: self.indexPath.row)
                            vc.homeCollectionView.reloadData()
                        }
                        
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
    
    @IBAction func superlikeBtnPressed(_ sender: Any) {

        if let lastSuperLikedTimeStampSeconds = self.currentUserDocument?["lastSuperLikedTime"] as? Int64 {
            let currentTimeInSeconds = Timestamp.init().seconds
            let dif = currentTimeInSeconds - lastSuperLikedTimeStampSeconds
            if(dif < 150) {
                UIApplication.showMessageWith("There should be difference of atleast 2 min and 30 seconds between two Superlikes")
                return
            }
        }
        
        SVProgressHUD.show()
        let personSuperLikedArr = self.userDocument?.data()["superLiked"] as? [String] ?? Array<String>()
        let myFullName = self.currentUserDocument?.data()["fullName"] as! String
        let personDeviceToken = self.userDocument?.data()["fcmToken"] as? String ?? ""
        let personName = self.userDocument?.data()["fullName"] as! String
        let personId = self.userDocument?.data()["userId"] as! String
        var superLikedArr = self.currentUserDocument?.data()["superLiked"] as? [String] ?? Array<String>()
        var likedArr = self.currentUserDocument?.data()["liked"] as? [String] ?? Array<String>()
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
        print(unreadMatchesCount)
        self.currentUserDocument?.reference.updateData(["superLiked":superLikedArr, "liked": likedArr, "lastSuperLikedTime":Timestamp.init().seconds, "unreadMatchesCount":currentUserUnreadMatchesCount], completion: { (error) in
            
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
                self.userDocument?.reference.updateData(["unreadSuperLikesCount":self.unreadSuperLikesCount, "unreadMatchesCount":self.unreadMatchesCount], completion: { (error) in
                    SVProgressHUD.dismiss()
                    if let vc = UIApplication.visibleViewController as? HomeViewController {
                         vc.viewWillAppear(false)
                    }
                  //  vc.itemsArr.remove(at: self.indexPath.row)
                   // vc.homeCollectionView.reloadData()
                   
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
        
    
}
