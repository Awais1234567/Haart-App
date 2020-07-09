//
//  UIImageView_Ext.swift
//  FusumaExample
//
//  Created by CSPC178 on 16/11/17.
//  Copyright © 2017 ytakzk. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    var imageScale: CGSize {
        let sx = Double(self.frame.size.width / self.image!.size.width)
        let sy = Double(self.frame.size.height / self.image!.size.height)
        var s = 1.0
        switch (self.contentMode) {
        case .scaleAspectFit:
            s = fmin(sx, sy)
            return CGSize (width: s, height: s)
            
        case .scaleAspectFill:
            s = fmax(sx, sy)
            return CGSize(width:s, height:s)
            
        case .scaleToFill:
            return CGSize(width:sx, height:sy)
            
        default:
            return CGSize(width:s, height:s)
        }
    }
}
