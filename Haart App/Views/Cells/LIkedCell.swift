//
//  LIkedCell.swift
//  Haart App
//
//  Created by Stone on 14/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
import SDWebImage

class LIkedCell: FriendCell {
    
    //@IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var statusCell: UILabel!
//     let db = Firestore.firestore()
//    let user:User = Auth.auth().currentUser!
//    var userDocument:QueryDocumentSnapshot!
//    var listType:ListType = .followers
//    @IBOutlet weak var imgView: UIImageView!
//    @IBOutlet weak var actionBtn: UIButton!
//    var channelReference: Query {
//        return db.collection("channels").whereField("userIds", arrayContains: user.uid)
//    }
   // @IBOutlet weak var nameLbl: UILabel!
//    @IBOutlet weak var userNameLbl: UILabel!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        imgView.layer.cornerRadius = imgView.frame.size.height / 2.0
//        imgView.clipsToBounds = true
//
//        actionBtn.layer.cornerRadius = actionBtn.frame.size.height / 2.0
//        actionBtn.clipsToBounds = true
//
//        actionBtn.superview!.layer.cornerRadius = 8
//        actionBtn.superview!.clipsToBounds = true
//    }
//
//    @IBAction func chatBtnPressed(_ sender: Any) {
//        createChannelAndPushVc()
//    }
//    @IBAction func actionBtnPressed(_ sender: Any) {
//        let data = userDocument.data()
//        if(listType == .followed) {
//            unfollow(personUserId: data["userId"] as! String)
//        }
//        else if(listType == .followers) {
//            blockAccount(personUserId: data["userId"] as! String)
//        }
//        else if(listType == .pending) {
//            acceptFollowRequest(personUserId: data["userId"] as! String, status: "")
//        }
//        else if(listType == .suggested) {
//            followRequest(personUserId: data["userId"] as! String, status: "")
//        }
//    }
//
    override func configureWith(userDocument:QueryDocumentSnapshot, currentUserSnapshot:QueryDocumentSnapshot, listType:ListType) {
        self.userDocument = userDocument
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


        if((currentUserSnapshot.data()["superLiked"] as? [String] ?? [String]()).contains(userDocument.data()["userId"] as! String) && (userDocument.data()["superLiked"] as? [String] ?? [String]()).contains(user.uid)) {
            statusCell.text = "It's A Super Match"
        }
        else if((currentUserSnapshot.data()["superLiked"] as? [String] ?? [String]()).contains(userDocument.data()["userId"] as! String) || (userDocument.data()["superLiked"] as? [String] ?? [String]()).contains(user.uid)) {
            if((userDocument.data()["superLiked"] as? [String] ?? [String]()).contains(user.uid)) {
                statusCell.text = "\(userDocument.data()["fullName"] as! String) Has Super Liked Your Profile"
            }
            else if((userDocument.data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
                statusCell.text = "\(userDocument.data()["fullName"] as! String) Has Liked Your Profile"
            }
            else {
                statusCell.text = ""
            }
        }
        else if((currentUserSnapshot.data()["liked"] as? [String] ?? [String]()).contains(userDocument.data()["userId"] as! String) && (userDocument.data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
            statusCell.text = "It's A Match"
        }
        else if((currentUserSnapshot.data()["liked"] as? [String] ?? [String]()).contains(userDocument.data()["userId"] as! String) || (userDocument.data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
            if((userDocument.data()["liked"] as? [String] ?? [String]()).contains(user.uid)) {
                statusCell.text = "\(userDocument.data()["fullName"] as! String) Has Liked Your Profile"
            }
            else {
                statusCell.text = ""
            }
        }

        
        super.configureWith(userDocument: userDocument, currentUserSnapshot: currentUserSnapshot, listType: .suggested)
//        if((currentUserSnapshot.data()["followedBy"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
//            actionBtn.setTitle("Block", for: .normal)
//            actionBtn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 1 / 255.0, alpha: 1)
//            listType = .followers
//        }
//        else if ((currentUserSnapshot.data()["followed"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)) {
//            actionBtn.setTitle("Unfollow", for: .normal)
//            actionBtn.backgroundColor = UIColor.init(red: 68/255.0, green: 69/255.0, blue: 70 / 255.0, alpha: 1)
//            listType = .followed
//        }
//        else if ((currentUserSnapshot.data()["suggested"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)){
//            actionBtn.setTitle("Follow", for: .normal)
//            actionBtn.backgroundColor = .red
//            listType = .suggested
//        }
//        else if ((currentUserSnapshot.data()["pending"] as? Array<String> ?? Array<String>()).contains(userDocument.data()["userId"] as! String)){
//            actionBtn.setTitle("Accept", for: .normal)
//            actionBtn.backgroundColor = UIColor.init(red: 0, green: 180/255.0, blue: 0, alpha: 1)
//            listType = .pending
//        }
//        else {
//            actionBtn.setTitle("Follow", for: .normal)
//            actionBtn.backgroundColor = .red
//            listType = .suggested
//        }
    }
//
//    func createChannelAndPushVc() {
//        let user = userDocument.data()
//        let channelName = user["fullName"] as! String
//        let recieverId = user["userId"] as! String
//        let userName = user["userName"] as! String
//        var profilePic = ""
//        if let imgsArr = (user["bioPics"] as? [String]) {
//            if(imgsArr.count > 0) {
//                profilePic = imgsArr[0]
//            }
//        }
//        SVProgressHUD.show()
//        self.channelReference.getDocuments(completion: { (snapshot, error) in
//
//            var doc:QueryDocumentSnapshot?
//            for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
//                if((document.data()["userIds"] as! NSArray).contains(recieverId)) {
//                    doc = document
//                    break
//                }
//            }
//            SVProgressHUD.dismiss()
//            if (doc != nil) {
//                let channel = Channel.init(document: doc!)
//                let vc = ChatViewController(user: self.user, channel: channel!)
//                UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
//            }
//            else {
//                SVProgressHUD.show()
//                let channel = Channel(name: channelName, createrName: AppSettings.fullName,createrId: self.user.uid, userIds: [recieverId, self.user.uid], userName:userName, profilePicUrl:profilePic, createrProfilePicUrl:AppSettings.profilePicUrl, createUserName:AppSettings.userName)
//                self.db.collection("channels").addDocument(data: channel.representation) { error in
//                    SVProgressHUD.dismiss()
//                    if let e = error {
//                        UIApplication.showMessageWith(e.localizedDescription)
//                        print("Error saving channel: \(e.localizedDescription)")
//                    }
//                    else {
//                        SVProgressHUD.show()
//                        self.channelReference.getDocuments(completion: { (snapshot, error) in
//                            var doc:QueryDocumentSnapshot?
//                            for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
//                                if((document.data()["userIds"] as! NSArray).contains(recieverId)) {
//                                    doc = document
//                                    break
//                                }
//                            }
//                            SVProgressHUD.dismiss()
//                            if (doc != nil) {
//                                let channel = Channel.init(document: doc!)
//                                let vc = ChatViewController(user: self.user, channel: channel!)
//                                UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
//                            }
//                        })
//                    }
//                }
//            }
//        })
//    }
//    func followRequest(personUserId:String, status:String) {
//
//        SVProgressHUD.show()
//        let ref1 = db.collection("users").whereField("userId", isEqualTo: user.uid)
//        ref1.getDocuments { (snapshot, error) in
//            let document = snapshot?.documents[0]
//            var followedArr = document?.data()["followed"] as? [String] ?? Array<String>()
//            followedArr.append(personUserId)
//
//            document?.reference.updateData(["followed":followedArr], completion: { (error) in
//
//                if let e = error {
//                    UIApplication.showMessageWith(e.localizedDescription)
//                }
//                else {
//                    let ref = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
//                    ref.getDocuments { (snapshot, error) in
//                        let document = snapshot?.documents[0]
//                        var followRequestsArr = document?.data()["pending"] as? [String] ?? Array<String>()
//                        followRequestsArr.append(self.user.uid)
//
//                        document?.reference.updateData(["pending":followRequestsArr], completion: { (error) in
//                            if let e = error {
//                                UIApplication.showMessageWith(e.localizedDescription)
//                            }
//                            SVProgressHUD.dismiss()
//                            UIApplication.visibleViewController.viewWillAppear(false)
//                        })
//                    }
//                }
//            })
//        }
//    }
//
//    func acceptFollowRequest(personUserId:String, status:String) {
//        SVProgressHUD.show()
//        let ref = db.collection("users").whereField("userId", isEqualTo: user.uid)
//        ref.getDocuments { (snapshot, error) in
//            let document = snapshot?.documents[0]
//            var followedByArr = document?.data()["followedBy"] as? [String] ?? Array<String>()
//            var followRequestsArr = document?.data()["pending"] as? [String] ?? Array<String>()
//            followedByArr.append(personUserId)
//            for i in 0..<(followRequestsArr.count) {
//                if(followRequestsArr[i] == personUserId) {
//                    followRequestsArr.remove(at: i)
//                    break
//                }
//            }
//            document?.reference.updateData(["pending":followRequestsArr, "followedBy":followedByArr], completion: { (error) in
//                SVProgressHUD.dismiss()
//                if let e = error {
//                    UIApplication.showMessageWith(e.localizedDescription)
//                }
//                UIApplication.visibleViewController.viewWillAppear(false)
//            })
//        }
//    }
//
//    func unfollow(personUserId:String) {
//        SVProgressHUD.show()
//        let ref1 = db.collection("users").whereField("userId", isEqualTo: user.uid)
//        ref1.getDocuments { (snapshot, error) in
//            let document = snapshot?.documents[0]
//            var followedArr = document?.data()["followed"] as? [String] ?? Array<String>()
//            for i in 0..<(followedArr.count) {
//                if(followedArr[i] == personUserId) {
//                    followedArr.remove(at: i)
//                    break
//                }
//            }
//            document?.reference.updateData(["followed":followedArr], completion: { (error) in
//
//                if let e = error {
//                    UIApplication.showMessageWith(e.localizedDescription)
//                }
//                else {
//                    let ref = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
//                    ref.getDocuments { (snapshot, error) in
//                        let document = snapshot?.documents[0]
//                        var followRequestsArr = document?.data()["pending"] as? [String] ?? Array<String>()
//                        for i in 0..<(followRequestsArr.count) {
//                            if(followRequestsArr[i] == self.user.uid) {
//                                followRequestsArr.remove(at: i)
//                                break
//                            }
//                        }
//                        var followedByArr = document?.data()["followedBy"] as? [String] ?? Array<String>()
//                        for i in 0..<(followedByArr.count) {
//                            if(followedByArr[i] == self.user.uid) {
//                                followedByArr.remove(at: i)
//                                break
//                            }
//                        }
//                        document?.reference.updateData(["pending":followRequestsArr, "followedBy":followedByArr], completion: { (error) in
//                            if let e = error {
//                                UIApplication.showMessageWith(e.localizedDescription)
//                            }
//                            SVProgressHUD.dismiss()
//                            UIApplication.visibleViewController.viewWillAppear(false)
//                        })
//                    }
//                }
//            })
//        }
//    }
//
//    func blockAccount(personUserId:String) {
//        SVProgressHUD.show()
//        let ref = db.collection("users").whereField("userId", isEqualTo: user.uid)
//        ref.getDocuments { (snapshot, error) in
//            let document = snapshot?.documents[0]
//            var blockedArr = document?.data()["blocked"] as? [String] ?? Array<String>()
//            var followedArr = document?.data()["followed"] as? [String] ?? Array<String>()
//            for i in 0..<(followedArr.count) {
//                if(followedArr[i] == personUserId) {
//                    followedArr.remove(at: i)
//                    break
//                }
//            }
//            blockedArr.append(personUserId)
//            document?.reference.updateData(["blocked":blockedArr, "followed":followedArr], completion: { (error) in
//                SVProgressHUD.dismiss()
//                if let e = error {
//                    UIApplication.showMessageWith(e.localizedDescription)
//                }
//                UIApplication.visibleViewController.viewWillAppear(false)
//            })
//        }
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
    
//    @IBAction func btnPressed(_ sender: Any) {
//    }
    
//    @IBAction func btnClicked(_ sender: Any) {
//    }
}
