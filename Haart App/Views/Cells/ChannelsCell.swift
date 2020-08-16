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
    var timeLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = lbl.font.withSize(12)
        lbl.textColor = UIColor.init(hexString: "#617798").withAlphaComponent(0.5)
        lbl.textColor = UIColor.lightGray
        return lbl
    }()
    var isActiveCircleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.incommingMsgColor
        view.layer.cornerRadius = 5
        return view
        
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
        addSubview(timeLbl)
        addSubview(isActiveCircleView)
        NSLayoutConstraint.activate([
            outerCircleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            outerCircleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            outerCircleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            outerCircleView.widthAnchor.constraint(equalToConstant: 70),
            outerCircleView.heightAnchor.constraint(equalToConstant: 70),
            
            imgView.centerXAnchor.constraint(equalTo: outerCircleView.centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: outerCircleView.centerYAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 58),
            imgView.heightAnchor.constraint(equalToConstant: 58),
            
            nameLbl.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 20),
            nameLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            timeLbl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            timeLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            isActiveCircleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            isActiveCircleView.widthAnchor.constraint(equalToConstant: 10),
            isActiveCircleView.heightAnchor.constraint(equalToConstant: 10),
            isActiveCircleView.bottomAnchor.constraint(equalTo: timeLbl.topAnchor, constant: -2)
        ])
    }
    func setData(channel:Channel) {
        
        self.selectionStyle = .none
        timeLbl.text = channel.timeStamp.formattedRelativeString()
        if(channel.createrId == Auth.auth().currentUser?.uid) {
            nameLbl.text = channel.name
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.imgView.sd_setImage(with: URL(string:channel.profilePicUrl), placeholderImage: nil)
            for i in channel.userIds{
                if i != channel.createrId{
                    getUserActiveState(id: i)
                }
            }
            
        }
        else {
            nameLbl.text = channel.createrName
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            self.imgView.sd_setImage(with: URL(string:channel.createrProfilePicUrl), placeholderImage: nil)
            getUserActiveState(id: channel.createrId)
            for i in channel.userIds{
                if i == channel.createrId{
                    getUserActiveState(id: i)
                }
            }
        }
    }
    func getUserActiveState(id: String){
        let controller = AbstractControl()
        let ref = controller.db.collection("users").whereField("userId", isEqualTo: id)
        ref.addSnapshotListener({(snapshot, error)in
            let state = snapshot?.documents[0].data()["isActive"] as? String ?? "0"
            if state == "0"{
                self.isActiveCircleView.backgroundColor = UIColor.incommingMsgColor
                self.outerCircleView.layer.borderColor = UIColor.init(hexString: "#617798").withAlphaComponent(0.5).cgColor
            }else{
                self.isActiveCircleView.backgroundColor = UIColor.green
                self.outerCircleView.layer.borderColor = UIColor.green.cgColor
            }
        })
    }
}
