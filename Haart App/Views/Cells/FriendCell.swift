//
//  FriendCell.swift
//  Haart App
//
//  Created by Stone on 25/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import SDWebImage
class FriendCell: UITableViewCell {
     let db = Firestore.firestore()
    let user:User = Auth.auth().currentUser!
    var userDocument:QueryDocumentSnapshot!
    var currentUserDocument:QueryDocumentSnapshot!
    var listType:ListType = .followers
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userNameTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
     var channelReference: Query {
        return db.collection("channels").whereField("userIds", arrayContains: user.uid)
    }
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var actionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.layer.cornerRadius = imgView.frame.size.height / 2.0
        imgView.clipsToBounds = true
       
        actionBtn.layer.cornerRadius = actionBtn.frame.size.height / 2.0
        actionBtn.clipsToBounds = true
        
        actionBtn.superview!.layer.cornerRadius = 8
        actionBtn.superview!.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func configureWith(userDocument:QueryDocumentSnapshot, currentUserSnapshot:QueryDocumentSnapshot, listType:ListType) {
        actionBtn.setHidden(false, animated: false)
        chatBtn.setHidden(false, animated: false)
        
        self.userDocument = userDocument
        currentUserDocument = currentUserSnapshot
        let userData = userDocument.data()
        nameLbl.text = userData["fullName"] as? String
        userNameLbl.text = userData["userName"] as? String
        if let imgsArr = (self.userDocument?.data()["bioPics"] as? [String]) {
            if(imgsArr.count > 0) {
                self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                self.imgView.sd_setImage(with: URL(string:imgsArr[0]), placeholderImage: nil)
            }
        }
        
        print("my data ",currentUserSnapshot.data())
        print("others data ",userData)
        if(listType == .allUsers) {
            if let trailing = userNameTrailing {
                userNameLbl.removeConstraints([trailing])
            }
            chatBtn.setHidden(true, animated: false)
            actionBtn.setHidden(true, animated: false)
//            actionBtn.setTitle("Block", for: .normal)
//            actionBtn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1 / 255.0, alpha: 1)
//            self.listType = .allUsers
        }
        else if(listType == .followers) {
            if ((currentUserSnapshot.data()["followed"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
                actionBtn.setTitle("Unfollow", for: .normal)
                actionBtn.backgroundColor = UIColor.init(red: 68/255.0, green: 69/255.0, blue: 70 / 255.0, alpha: 1)
                self.listType = .followed
            }
            else if ((currentUserSnapshot.data()["requestSent"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
                actionBtn.setTitle("Cancel", for: .normal)
                actionBtn.backgroundColor = .red
                self.listType = .pending
                actionBtn.tag = 0
            }
            else {
                actionBtn.setTitle("Follow", for: .normal)
                actionBtn.backgroundColor = .red
                self.listType = .suggested
            }
        }
        else if(listType == .followed) {
            actionBtn.setTitle("Unfollow", for: .normal)
            actionBtn.backgroundColor = UIColor.init(red: 68/255.0, green: 69/255.0, blue: 70 / 255.0, alpha: 1)
            self.listType = .followed
        }
        else if ((currentUserSnapshot.data()["pending"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)){
            actionBtn.setTitle("Accept", for: .normal)
            actionBtn.backgroundColor = UIColor.init(red: 0, green: 180/255.0, blue: 0, alpha: 1)
            self.listType = .pending
            actionBtn.tag = 1
        }
        else if ((currentUserSnapshot.data()["requestSent"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
            actionBtn.setTitle("Cancel", for: .normal)
            actionBtn.backgroundColor = .red
            self.listType = .pending
            actionBtn.tag = 0
        }
        else if ((currentUserSnapshot.data()["followed"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
            actionBtn.setTitle("Unfollow", for: .normal)
            actionBtn.backgroundColor = UIColor.init(red: 68/255.0, green: 69/255.0, blue: 70 / 255.0, alpha: 1)
            self.listType = .followed
        }

        else if((currentUserSnapshot.data()["followedBy"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
                actionBtn.setTitle("Follow", for: .normal)
                actionBtn.backgroundColor = .red
            self.listType = .suggested
        }
            
        else if ((currentUserSnapshot.data()["suggested"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)){
            actionBtn.setTitle("Follow", for: .normal)
            actionBtn.backgroundColor = .red
            self.listType = .suggested
        }
        
        else {
            actionBtn.setTitle("Follow", for: .normal)
            actionBtn.backgroundColor = .red
            self.listType = .suggested
        }
}
    @IBAction func chatBtnPressed(_ sender: Any) {
        createChannelAndPushVc()
    }
    
    func createChannelAndPushVc() {
                    let user = userDocument.data()
                    let channelName = user["fullName"] as! String
                    let recieverId = user["userId"] as! String
                    let userName = user["userName"] as! String
                    var profilePic = ""
                    if let imgsArr = (user["bioPics"] as? [String]) {
                            if(imgsArr.count > 0) {
                                profilePic = imgsArr[0]
                            }
                    }
                SVProgressHUD.show()
                self.channelReference.getDocuments(completion: { (snapshot, error) in
                    
                    var doc:QueryDocumentSnapshot?
                    for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
                        if((document.data()["userIds"] as! NSArray).contains(recieverId)) {
                            doc = document
                            break
                        }
                    }
                    SVProgressHUD.dismiss()
                    if (doc != nil) {
                        let channel = Channel.init(document: doc!)
                        let vc = ChatViewController(user: self.user, channel: channel!)
                        UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
                    }
                    else {
                        SVProgressHUD.show()
                        let channel = Channel(name: channelName, createrName: AppSettings.fullName,createrId: self.user.uid, userIds: [recieverId, self.user.uid], userName:userName, profilePicUrl:profilePic, createrProfilePicUrl:AppSettings.profilePicUrl, createUserName:AppSettings.userName)
                        self.db.collection("channels").addDocument(data: channel.representation) { error in
                            SVProgressHUD.dismiss()
                            if let e = error {
                                UIApplication.showMessageWith(e.localizedDescription)
                                print("Error saving channel: \(e.localizedDescription)")
                            }
                            else {
                                SVProgressHUD.show()
                                self.channelReference.getDocuments(completion: { (snapshot, error) in
                                    var doc:QueryDocumentSnapshot?
                                    for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
                                        if((document.data()["userIds"] as! NSArray).contains(recieverId)) {
                                            doc = document
                                            break
                                        }
                                    }
                                    SVProgressHUD.dismiss()
                                    if (doc != nil) {
                                        let channel = Channel.init(document: doc!)
                                        let vc = ChatViewController(user: self.user, channel: channel!)
                                    UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
                                    }
                                })
                            }
                        }
                    }
                })
    }
    
    @IBAction func btnClicked(_ sender: UIButton) {
        let data = userDocument.data()
        if(listType == .allUsers) {
            blockAccount(personUserId: data["userId"] as! String)
        }
        else if(listType == .followed) {
            unfollow(personUserId: data["userId"] as! String)
        }
        else if(listType == .followers) {
            followRequest(personUserId: data["userId"] as! String, status: "")
            //blockAccount(personUserId: data["userId"] as! String)
        }
        else if(listType == .pending) {
            if(sender.tag == 0) {//sent
                cancelFollowRequest(personUserId: data["userId"] as! String)
            }
            else {//received
                acceptFollowRequest(personUserId: data["userId"] as! String, status: "")

            }
        }
        else if(listType == .suggested) {
            followRequest(personUserId: data["userId"] as! String, status: "")
        }
    }
    
    
    func cancelFollowRequest(personUserId:String) {
         SVProgressHUD.show()
//        let myRef = db.collection("users").whereField("userId", isEqualTo: user.uid)
//        myRef.getDocuments { (snapshot, error) in
          //  let document = currentUserDocument//snapshot?.documents[0]
            var requestSentArr = currentUserDocument?.data()["requestSent"] as? [String] ?? Array<String>()
            for i in 0..<(requestSentArr.count) {
                if(requestSentArr[i] == personUserId) {
                    requestSentArr.remove(at: i)
                    break
                }
            }
            currentUserDocument?.reference.updateData(["requestSent" : requestSentArr], completion: { (error) in
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                     SVProgressHUD.dismiss()
                }
                else {
                 //   let otherUserRef = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                  //  otherUserRef.getDocuments(completion: { (snapshot, error) in
                      //  if(snapshot?.documents.count ?? 0 > 0) {
                          //  let document = snapshot?.documents[0]
                    var pendingArr = self.userDocument?.data()["pending"] as? [String] ?? Array<String>()
                            for i in 0..<(pendingArr.count) {
                                if(pendingArr[i] == self.user.uid) {
                                    pendingArr.remove(at: i)
                                    break
                                }
                            }
                    self.userDocument?.reference.updateData(["pending":pendingArr], completion: { (error) in
                                SVProgressHUD.dismiss()
                            })
                       // }
                  //  })
                    UIApplication.visibleViewController.viewWillAppear(false)

                }
            })
       // }
    }
    func followRequest(personUserId:String, status:String) {
        
        SVProgressHUD.show()
        //let ref1 = db.collection("users").whereField("userId", isEqualTo: user.uid)
      //  ref1.getDocuments { (snapshot, error) in
      //      let document = snapshot?.documents[0]
            let myName = currentUserDocument?.data()["fullName"] as? String ?? ""
            var requestSentArr = currentUserDocument?.data()["requestSent"] as? [String] ?? Array<String>()
        if(!requestSentArr.contains(personUserId)) {
             requestSentArr.append(personUserId)
        }
            currentUserDocument?.reference.updateData(["requestSent":requestSentArr], completion: { (error) in
                
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                   // let ref = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                  //  ref.getDocuments { (snapshot, error) in
                    //    let document = snapshot?.documents[0]
                    var followRequestsArr = self.userDocument?.data()["pending"] as? [String] ?? Array<String>()
                    if(!followRequestsArr.contains(self.user.uid)) {
                        followRequestsArr.append(self.user.uid)
                    }
                    let token = (self.userDocument?.data()["fcmToken"] as? String ?? "")
                    PushNotificationSender().sendPushNotification(to: token, title: "Follow Request:", body: "\(myName) sent you follow request.", type: "Follow Request", id: self.user.uid)
                    self.userDocument?.reference.updateData(["pending":followRequestsArr], completion: { (error) in
                            if let e = error {
                                UIApplication.showMessageWith(e.localizedDescription)
                            }
                            SVProgressHUD.dismiss()
                            UIApplication.visibleViewController.viewWillAppear(false)
                        })
                    //}
                }
            })
       // }
        
        
    }
    
    func acceptFollowRequest(personUserId:String, status:String) {
        SVProgressHUD.show()
     //   let ref = db.collection("users").whereField("userId", isEqualTo: user.uid)
        
      //  ref.getDocuments { (snapshot, error) in
       //     let document = snapshot?.documents[0]
            let myName = currentUserDocument?.data()["fullName"] as? String ?? ""
            var followedByArr = currentUserDocument?.data()["followedBy"] as? [String] ?? Array<String>()
            var followRequestsArr = currentUserDocument?.data()["pending"] as? [String] ?? Array<String>()
            if(!followedByArr.contains(personUserId)) {
                followedByArr.append(personUserId)
            }
        
            for i in 0..<(followRequestsArr.count) {
                if(followRequestsArr[i] == personUserId) {
                    followRequestsArr.remove(at: i)
                    break
                }
            }
            currentUserDocument?.reference.updateData(["pending":followRequestsArr, "followedBy":followedByArr], completion: { (error) in
                SVProgressHUD.dismiss()
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                else {
                  //  let requesterRef = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                 //   requesterRef.getDocuments { (snapshot, error) in
                   //     if(snapshot?.documents.count ?? 0 > 0) {
                            
                          //  let document = snapshot?.documents[0]
                            var followed = self.userDocument?.data()["followed"] as? [String] ?? Array<String>()
                    if(!followed.contains(self.user.uid)){
                        followed.append(self.user.uid)
                    }
                    
                            var requestsSent = self.userDocument?.data()["requestSent"] as? [String] ?? Array<String>()
                            for i in 0..<(requestsSent.count) {
                                if(requestsSent[i] == self.user.uid) {
                                    requestsSent.remove(at: i)
                                    break
                                }
                            }
                            self.userDocument?.reference.updateData(["requestSent":requestsSent, "followed": followed], completion: { (error) in
                                PushNotificationSender().sendPushNotification(to: self.userDocument?.data()["fcmToken"] as? String ?? "", title: "Request Accepted:", body: "\(myName) has accepted your follow request.", type: "Request Accepted", id: self.user.uid)

                            })
                            
                  //      }
                        SVProgressHUD.dismiss()
                  //  }
                }
                UIApplication.visibleViewController.viewWillAppear(false)
            })
      //  }
    }
    
    func unfollow(personUserId:String) {
        SVProgressHUD.show()
      //  let ref1 = db.collection("users").whereField("userId", isEqualTo: user.uid)
     //   ref1.getDocuments { (snapshot, error) in
         //   let document = snapshot?.documents[0]
            var followedArr = currentUserDocument?.data()["followed"] as? [String] ?? Array<String>()
            for i in 0..<(followedArr.count) {
                if(followedArr[i] == personUserId) {
                    followedArr.remove(at: i)
                    break
                }
            }
            currentUserDocument?.reference.updateData(["followed":followedArr], completion: { (error) in
                
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                else {
                 //   let ref = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                   // ref.getDocuments { (snapshot, error) in
                   //     let document = snapshot?.documents[0]
                        var followRequestsArr = self.userDocument?.data()["pending"] as? [String] ?? Array<String>()
                        for i in 0..<(followRequestsArr.count) {
                            if(followRequestsArr[i] == self.user.uid) {
                                followRequestsArr.remove(at: i)
                                break
                            }
                        }
                        var followedByArr = self.userDocument?.data()["followedBy"] as? [String] ?? Array<String>()
                        for i in 0..<(followedByArr.count) {
                            if(followedByArr[i] == self.user.uid) {
                                followedByArr.remove(at: i)
                                break
                            }
                        }
                        self.userDocument?.reference.updateData(["pending":followRequestsArr, "followedBy":followedByArr], completion: { (error) in
                            if let e = error {
                                UIApplication.showMessageWith(e.localizedDescription)
                            }
                            SVProgressHUD.dismiss()
                            UIApplication.visibleViewController.viewWillAppear(false)
                        })
                  //  }
                }
            })
       // }
    }
    
    func blockAccount(personUserId:String) {
        SVProgressHUD.show()
      //  let ref = db.collection("users").whereField("userId", isEqualTo: user.uid)
      //  ref.getDocuments { (snapshot, error) in
        //    let document = snapshot?.documents[0]
            var blockedArr = currentUserDocument?.data()["blocked"] as? [String] ?? Array<String>()
            var followedArr = currentUserDocument?.data()["followed"] as? [String] ?? Array<String>()
            for i in 0..<(followedArr.count) {
                if(followedArr[i] == personUserId) {
                    followedArr.remove(at: i)
                    break
                }
            }
        if(!blockedArr.contains(personUserId)) {
            blockedArr.append(personUserId)
        }
        
            currentUserDocument?.reference.updateData(["blocked":blockedArr, "followed":followedArr], completion: { (error) in
                SVProgressHUD.dismiss()
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription)
                }
                UIApplication.visibleViewController.viewWillAppear(false)
            })
       // }
    }
    
    
    @IBAction func otherUserProfileBtnPressed(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "OthersProfileViewController") as! OthersProfileViewController
        viewController.personId = userDocument.data()["userId"] as! String
        UIApplication.visibleViewController.navigationController?.pushViewController(viewController, animated: true)
    }
}
