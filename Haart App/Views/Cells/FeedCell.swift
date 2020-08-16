//
//  FeedCell.swift
//  Haart App
//
//  Created by Stone on 25/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseFirestore
import FirebaseDatabase
import AVFoundation
import AVKit

protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: FeedCell)
}

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var commentsCountLbl: UIButton!
    @IBOutlet weak var recentCommentLabel: UILabel!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var commenterNameLabel: UIButton!
    
    @IBOutlet weak var VideoView: UIView!
    
    
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    var post = [String:Any]()
    var commentsReference: CollectionReference!
    var likesReference : CollectionReference!
    var data:[String:Any]!
    var userDocument:QueryDocumentSnapshot?
    var state : Bool = true
    let cell = UITableViewCell()
    var playerLayer = AVPlayerLayer(player: nil)
    var player = AVPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        NotificationCenter.defaultCenter().addObserver(self,
//       selector: "playerItemDidReachEnd:",
//       name: AVPlayerItemDidPlayToEndTimeNotification,
//       object: self.playerL.currentItem)
           playerLayer.frame = VideoView.bounds
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(data:[String:Any]) {
        self.data = data
        if(data["id"] != nil){
            let postersID = data["id"] as? String ?? ""
            let userID : String = String(String(postersID.dropFirst(4)).dropLast(8))
            print("userID------->\(userID)")
            
            let ref2 = self.db.collection("users").whereField("userId", isEqualTo: userID)
            ref2.getDocuments { (snapshot, error) in
                if let e = error {
                    UIApplication.showMessageWith(e.localizedDescription )
                    return
                }
                if(self.userDocument == nil) {
                    
                }
                if(snapshot?.documents.count == 0) {
                }
                else {
                    print("running")
                    let bioPicsArr = snapshot?.documents[0].data()["bioPics"] as? [String] ?? ["","","","",""]
                    self.profilePicImgView.sd_setImage(with: URL(string: bioPicsArr[0]), placeholderImage: nil)
                }
            }
            
            fullName.text = data["fullName"] as? String ?? ""
            captionLbl.text = data["caption"] as? String ?? ""
           
            if(data["type"] as! String == "video"){
                let videoURL = NSURL(string: data["url"] as! String)
                 player = AVPlayer(url: videoURL! as URL)
                NotificationCenter.default.addObserver(self,
                selector: #selector(playerItemDidReachEnd),
                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                  object: player.currentItem)
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.9082125604, height: UIScreen.main.bounds.height * 0.3125)
                self.VideoView.layer.addSublayer(playerLayer)
                player.play()
                VideoView.isHidden = false
            }
            
       
            imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imgView.sd_setImage(with: URL(string:data["url"] as? String ?? "https://firebasestorage.googleapis.com/v0/b/haart-app-70f04.appspot.com/broken-1.png"), placeholderImage: nil)
            timeLbl.text = (data["timeStamp"] as? Timestamp)!.dateValue().feedTime()
            
            let path = ["posts", data["id"] as! String, "comments"].joined(separator: "/")
            
            commentsReference =  db.collection(path)//db.collection("comments_\(post["id"] ?? "")")
            commentsReference.getDocuments(completion: {(snapshot, error) in
                if let documents = snapshot?.documents {
                    self.commentsCountLbl.setTitle(String("Total \(documents.count) Comments"), for: .normal)
                    if !documents.isEmpty{
                        self.recentCommentLabel.text = documents[documents.count - 1].data()["comment"] as? String
                        
                let ref2 = self.db.collection("users").whereField("userId", isEqualTo: documents[documents.count - 1].data()["userId"]!)
                        ref2.getDocuments { (snapshot, error) in
                            if let e = error {
                                UIApplication.showMessageWith(e.localizedDescription )
                                return
                            }
                            if(self.userDocument == nil) {
                                
                            }
                            if(snapshot?.documents.count == 0) {
                            }
                            else {
                                self.commenterNameLabel.setTitle((snapshot?.documents[0].data()["fullName"] as! String), for: .normal)
                            }
                        }
                    }
                }
            })
            
            
              let path2 = ["posts", data["id"] as! String, "likes"].joined(separator: "/")
              likesReference =  db.collection(path2)
            likesReference.getDocuments(completion: {(snapshot, error) in
        if(snapshot?.documents.count ?? 0 > 0) {
            if let documents = snapshot?.documents {
                 let likesCheckArr = documents[0].data()["likes"] as? [String] ?? Array<String>()
                if(likesCheckArr.count == 1){
                              self.likesLabel.isHidden = false
                              self.likesLabel.text = "\(String(describing: likesCheckArr.count)) like"
                          }
                          if(likesCheckArr.count > 1){
                              self.likesLabel.isHidden = false
                              self.likesLabel.text = "\(String(describing: likesCheckArr.count)) likes"
                          }
                          if(likesCheckArr.count == 0){
                                             self.likesLabel.isHidden = true
                                         }
                    let checkID = self.defaults.value(forKey: "UserID") as! String
                                        if((likesCheckArr).contains(checkID)){
                                            self.likeImage.image = UIImage(named: "heartLike")
                                        }
                             }
        } else{
             self.likesLabel.isHidden = true
             print("no likes")
                }
           
            })
              
//            likesReference =  db.collection(path2)
//            likesReference.getDocuments(completion: {(snapshot, error) in
//                if let documents = snapshot?.documents {
//                    print(documents.count)
//                    print(self.defaults.value(forKey: "UserID") as! String)
//                    for i in 0..<(documents.count) {
//                        if(documents[i].data()["userId"] as! String == self.defaults.value(forKey: "UserID") as! String){
//                            print("likeheartjkasjasd")
//                            self.likeImage.image = UIImage(named: "heartLike")
//                        }
//                    }
//                }
                
            }
        
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
                  player.seek(to: CMTime.zero)
                 player.play()
              }
    @IBAction func commentBtnPressed(_ sender: Any) {
        let commentsViewController = CommentssViewController()
        commentsViewController.post = data// as? [String : Any] ?? [String : Any]()
        let controller = HaartNavBarController.init(rootViewController: commentsViewController)
        controller.modalPresentationStyle = .fullScreen
        UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
        //viewController.personId = userDocument.data()["userId"] as! String
        //UIApplication.visibleViewController.navigationController?.pushViewController(viewController, animated: true)
    }
    
    weak var delegate: PostActionCellDelegate?
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        let path2 = ["posts", data["id"] as! String, "likes"].joined(separator: "/")
                 likesReference =  db.collection(path2)
                 likesReference.getDocuments(completion: {(snapshot, error) in
             if(snapshot?.documents.count ?? 0 > 0) {
                 if let documents = snapshot?.documents {
                    if((documents[0].data()["likes"] as? Array<String> ?? [String]()).contains(self.defaults.value(forKey: "UserID") as! String)){
                        var likesCheckArr = documents[0].data()["likes"] as? [String] ?? Array<String>()
                        let checkID = self.defaults.value(forKey: "UserID") as! String
            if((likesCheckArr).contains(checkID)){
                if let index = likesCheckArr.firstIndex(of: checkID) {
                    print("the index \(index)")
                    likesCheckArr.remove(at: index)
                    print(likesCheckArr)
                    documents[0].reference.updateData(["likes" : likesCheckArr])
                    self.reloadInputViews()
                                   }
                               }
                         self.likeImage.image = UIImage(named: "Like_Gray")
                    } else{
                        self.likesReference.getDocuments(completion: {(snapshot, error) in
                            if(snapshot?.documents.count ?? 0 > 0) {
                                if let documents = snapshot?.documents {
                                var likesCheckArr = documents[0].data()["likes"] as? [String] ?? Array<String>()
                                    likesCheckArr.append(self.defaults.value(forKey: "UserID") as! String)
                            documents[0].reference.updateData(["likes" : likesCheckArr])
                                }
                            }
                        })
                        self.likeImage.image = UIImage(named: "heartLike")
                    }
            }
             } else{
                self.likesReference.addDocument(data: ["likes": ["\(self.defaults.value(forKey: "UserID") as! String)"]])
                 self.reloadInputViews()
                    }
        
        })
}
}
    



