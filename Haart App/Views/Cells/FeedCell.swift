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
    @IBOutlet weak var profilePicImgView: UIImageView!
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
        captionLbl.text = data["caption"] as? String ?? ""
        imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgView.sd_setImage(with: URL(string:data["url"] as! String), placeholderImage: nil)
        timeLbl.text = (data["timeStamp"] as! Timestamp).dateValue().feedTime()
    }
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        viewController.post = data// as? [String : Any] ?? [String : Any]()
        UIApplication.visibleViewController.present(HaartNavBarController.init(rootViewController: viewController), animated: true, completion: nil)
        //viewController.personId = userDocument.data()["userId"] as! String
        //UIApplication.visibleViewController.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        
    }
    
}
