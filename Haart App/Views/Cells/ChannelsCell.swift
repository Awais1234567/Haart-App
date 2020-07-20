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


class ChannelssCell: UITableViewCell {
    let outerCircleView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.init(hexString: "#617798").withAlphaComponent(0.5).cgColor
        view.layer.cornerRadius = 35
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var imgView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 29
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    var nameLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.init(hexString: "#617798")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    var userNameLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.init(hexString: "#617798").withAlphaComponent(0.5)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = lbl.font.withSize(14)
        lbl.textColor = UIColor.lightGray
        return lbl
    }()
    var timeLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = lbl.font.withSize(12)
        lbl.textColor = UIColor.init(hexString: "#617798").withAlphaComponent(0.5)
        lbl.textColor = UIColor.lightGray
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        insertBottomSeperatorLine()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func setupViews(){
        addSubview(outerCircleView)
        addSubview(imgView)
        addSubview(nameLbl)
        addSubview(userNameLbl)
        addSubview(timeLbl)
        NSLayoutConstraint.activate([
            outerCircleView.centerXAnchor.constraint(equalTo: imgView.centerXAnchor),
            outerCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            outerCircleView.widthAnchor.constraint(equalToConstant: 70),
            outerCircleView.heightAnchor.constraint(equalToConstant: 70),
            
            imgView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            imgView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 58),
            imgView.heightAnchor.constraint(equalToConstant: 58),
            
            nameLbl.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 20),
            nameLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 35),
            
            userNameLbl.leadingAnchor.constraint(equalTo: nameLbl.leadingAnchor),
            userNameLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 5),
            userNameLbl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -31),
            
            timeLbl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            timeLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
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
