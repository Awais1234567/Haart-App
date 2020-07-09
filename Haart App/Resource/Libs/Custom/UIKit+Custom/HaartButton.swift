//
//  HaartView.swift
//  Haart App
//
//  Created by Stone on 11/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class HaartButton: UIButton {

    var tempView:UIView!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if(tempView == nil) {
            tempView = UIView()
            tempView.frame = CGRect.init(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
            tempView.backgroundColor = .white
            self.addSubview(tempView)
            tempView.layer.cornerRadius = 10
            tempView.layer.masksToBounds = true
            tempView.isUserInteractionEnabled = false
            
        }
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset =  CGSize.zero
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 5
        self.backgroundColor = .clear
        
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.backgroundColor = .clear
    }
    
}
