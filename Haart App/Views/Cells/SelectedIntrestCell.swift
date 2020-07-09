//
//  SelectedIntrestCell.swift
//  Haart App
//
//  Created by Stone on 20/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
protocol SelectedIntrestCellDelegate: class {
    func removedItemAt(_ row: Int)
}
class SelectedIntrestCell: UICollectionViewCell {
    weak var delegate: SelectedIntrestCellDelegate?

    @IBOutlet weak var txtLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtLbl.borderWidth = 2
        txtLbl.layer.borderColor = UIColor.red.cgColor
    }

    @IBAction func removeBtnPressed(_ sender: UIButton) {
        delegate?.removedItemAt(sender.tag)
    }
    
}
