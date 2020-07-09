//
//  HaartTextView.swift
//  Haart App
//
//  Created by Stone on 11/02/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class HaartTextView: UITextView, UITextViewDelegate {
    
    var maxCharacterLimit = 0 // unlimited
    var placeholderText = ""
    var placeholderLabel:UILabel!
    var counterLbl:UILabel!
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.delegate = self
        if(maxCharacterLimit == 0) {
            self.contentInset = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        }
        else {
            self.contentInset = UIEdgeInsets.init(top: 10, left: 20, bottom: 20, right: 20)
        }
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.init(red: 243/255.0, green: 244/255.0, blue: 245/255.0, alpha: 1).cgColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        if(counterLbl == nil) {
            counterLbl = UILabel()
            counterLbl.isHidden = maxCharacterLimit == 0
            counterLbl.text = "0/\(maxCharacterLimit)"
            counterLbl.font = UIFont.systemFont(ofSize: 12)
            counterLbl.textColor = .gray
            self.superview!.addSubview(counterLbl)
        }
    
        if(placeholderLabel == nil) {
            placeholderLabel = UILabel()
            placeholderLabel.text = placeholderText
            placeholderLabel.font = self.font
            placeholderLabel.sizeToFit()
            self.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor.lightGray
            placeholderLabel.isHidden = !self.text.isEmpty
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if(counterLbl != nil && counterLbl.constraints.count == 0) {
            self.superview!.addVisualConstraints(["H:[view]-10-|", "V:[view]-7-|",], subviews: ["view":counterLbl])

        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        counterLbl.text = "\(self.text.count)/\(maxCharacterLimit)"
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (maxCharacterLimit == 0 || text.count == 0) {
            return true
        }
        else {
            if(self.text.count >= maxCharacterLimit) {
                return false
            }
        }
        return true
        
    }


}
