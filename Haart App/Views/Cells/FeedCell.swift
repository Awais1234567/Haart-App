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


class FeedCell: UITableViewCell {
  
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var commentsCountLbl: UIButton!
    @IBOutlet weak var recentCommentLabel: UILabel!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var commenterNameLabel: UIButton!
    let db = Firestore.firestore()
    var commentsReference: CollectionReference!
    var data:[String:Any]!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(data:[String:Any]) {
        self.data = data
        fullName.text = data["fullName"] as? String ?? ""
        commenterNameLabel.setTitle(data["fullName"] as? String ?? "", for: .normal)
        captionLbl.text = data["caption"] as? String ?? ""
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: URL(string:data["url"] as! String), placeholderImage: nil)
        timeLbl.text = (data["timeStamp"] as! Timestamp).dateValue().feedTime()
        
        let path = ["posts", data["id"] as! String, "comments"].joined(separator: "/")

        commentsReference =  db.collection(path)//db.collection("comments_\(post["id"] ?? "")")
        commentsReference.getDocuments(completion: {(snapshot, error) in
            if let documents = snapshot?.documents {
                self.commentsCountLbl.setTitle(String("Total \(documents.count) Comments"), for: .normal)
                if !documents.isEmpty{
                    self.recentCommentLabel.text = documents[documents.count - 1].data()["comment"] as? String
                }
            }
        })
    }
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsViewController = CommentssViewController()
        commentsViewController.post = data// as? [String : Any] ?? [String : Any]()
        let controller = HaartNavBarController.init(rootViewController: commentsViewController)
        controller.modalPresentationStyle = .fullScreen
        UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
        //viewController.personId = userDocument.data()["userId"] as! String
        //UIApplication.visibleViewController.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        
    }
    
}

