//
//  CommentCell.swift
//  Haart App
//
//  Created by Stone on 25/05/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CommentCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(userDocument:QueryDocumentSnapshot) {
        fullNameLbl.text = "Awais"//userDocument.data()["unreadLikesCount"] as? String
        commentLbl.text = userDocument.data()["comment"] as? String
        timeLbl.text = "1h"//userDocument.data()["unreadLikesCount"]
        profileImgView.image = UIImage(named: "Back")
    }
    
}
