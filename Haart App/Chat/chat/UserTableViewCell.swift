//
//  UserTableViewCell.swift
//  Haart App
//
//  Created by Awais Khalid on 25/07/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//


import UIKit

class UserTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    //@IBOutlet private weak var checkView: CheckView!
    var fullNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        return label
    }()
    
    //MARK: - Properties
    var fullName: String? {
        didSet {
            fullNameLabel.textColor = UIColor.black
            fullNameLabel.text = fullName
        }
    }
    
    var check: Bool? {
        didSet {
            //checkView.check = check
        }
    }
    
    var userImage: UIImage? {
        didSet {
            //userImageView.image = userImage
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews(){
        addSubview(fullNameLabel)
        
        NSLayoutConstraint.activate([
            fullNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            fullNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

