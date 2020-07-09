//
//  SettingsSimpleCell.swift
//  Haart App
//
//  Created by Stone on 06/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class SettingsSimpleCell: UITableViewCell {

    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var txtLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
