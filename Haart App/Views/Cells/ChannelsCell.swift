//
//  ChannelsCell.swift
//  Haart App
//
//  Created by Stone on 13/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ChannelsCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = imgView.frame.size.height / 2.0
        imgView.clipsToBounds = true
        imgView.superview!.layer.cornerRadius = 8
        imgView.superview!.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setData(channel:Channel) {
        self.selectionStyle = .none
        timeLbl.text = channel.timeStamp.formattedRelativeString()
        if(channel.createrId == Auth.auth().currentUser?.uid) {
            nameLbl.text = channel.name
            userNameLbl.text = channel.userName
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.imgView.sd_setImage(with: URL(string:channel.profilePicUrl), placeholderImage: nil)
        }
        else {
            nameLbl.text = channel.createrName
            userNameLbl.text = channel.createUserName
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.imgView.sd_setImage(with: URL(string:channel.createrProfilePicUrl), placeholderImage: nil)
        }
    }
}
