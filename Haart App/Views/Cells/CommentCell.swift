//
//  CommentCell.swift
//  Haart App
//
//  Created by Stone on 25/05/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseFirestore

class CommentCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    let db = Firestore.firestore()
    var commentsReference: CollectionReference!
       var userDocument:QueryDocumentSnapshot?
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImgView.layer.cornerRadius = profileImgView.frame.size.height / 2.0
     profileImgView.clipsToBounds = true
      profileImgView.superview!.layer.cornerRadius = 8
       profileImgView.superview!.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(userDocument:QueryDocumentSnapshot) {
        let ref2 = self.db.collection("users").whereField("userId", isEqualTo: userDocument.data()["userId"]!)
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
                                               print("hitt it")
                                           let bioPicsArr = snapshot?.documents[0].data()["bioPics"] as? [String] ?? ["","","","",""]
                                            self.fullNameLbl.text = snapshot?.documents[0].data()["fullName"] as? String
                                            self.profileImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                            self.profileImgView.sd_setImage(with: URL(string: bioPicsArr[0]), placeholderImage: nil)
                                        
                                       }
                                   }
      
        commentLbl.text = userDocument.data()["comment"] as? String
        timeLbl.text = (userDocument.data()["timeStamp"] as! Timestamp).dateValue().feedTime()
    }
    
}
