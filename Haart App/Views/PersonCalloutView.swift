//
//  PersonCalloutView.swift
//  Haart App
//
//  Created by Stone on 13/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SDWebImage
class PersonCalloutView: UIView {

    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var ethnicityLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        let view =  Bundle.main.loadNibNamed("PersonCalloutView", owner: self, options: nil)![0] as! UIView
//        self.addSubview(view)
    }
    
    func set(userName:String,name:String,dob:String?,ethnicity:String, imgUrl:String) {
        userNameLbl.text = userName
        fullNameLbl.text = name
        self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
        self.imgView.sd_setImage(with: URL(string:imgUrl), placeholderImage: nil)
        if let dob = dob {
            if(dob.count > 0) {
                ageLbl.text = "\(dob.getAgeFromDOB().0.string) year"
            }
        }
        else {
            ageLbl.text = ""
        }
        ethnicityLbl.text = ethnicity
    }

}
