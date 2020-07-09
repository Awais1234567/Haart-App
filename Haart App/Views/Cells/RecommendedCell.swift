//
//  RecommendedCell.swift
//  Haart App
//
//  Created by Stone on 31/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

class RecommendedCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgView2: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    @IBOutlet weak var userNameLbl2: UILabel!
    func addLongPressGesture() { // to drag image from list in editor view
        if let recommendedVc = UIApplication.visibleViewController as? RecommendedViewController {
            //  method is in EditViewControl class
            let longPressGesture = UILongPressGestureRecognizer.init(target: recommendedVc, action: #selector(recommendedVc.longPressGesture(sender: )))
            if(imgView != nil) {
                imgView?.addGestureRecognizer(longPressGesture)
                imgView.isUserInteractionEnabled = true
            }
            if(imgView2 != nil) {
                imgView2?.addGestureRecognizer(longPressGesture)
                imgView2.isUserInteractionEnabled = true
            }
        }
    }
}
