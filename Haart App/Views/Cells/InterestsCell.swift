//
//  InterestsCell.swift
//  Haart App
//
//  Created by Stone on 15/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class InterestsCell: UITableViewCell {

    @IBOutlet weak var textLbl: UILabel!
    
    @IBOutlet weak var heartImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
