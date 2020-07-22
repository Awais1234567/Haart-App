//
//  PorfileImageCell.swift
//  Haart App
//
//  Created by OBS on 20/07/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import UIKit

class ProfileImageViewCell : UICollectionViewCell{
    
    lazy var imageView : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
     
        return iv
    }()
    
    
    static var identifier: String = "MenuCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        setupCell()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    

        func setupCell(){
            self.addSubview(imageView)
      
            
            NSLayoutConstraint.activate([
                
                
                imageView.topAnchor.constraint(equalTo: self.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                
              
                
            ])
        }
        
    
    
}
