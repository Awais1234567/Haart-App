//
//  FlowLayout.swift
//  CardsApp
//
//  Created by Raman on 22/11/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import Foundation
import UIKit
/*Layouts for all the collection lists*/

class FlowLayout {
    
    static var cardsFlowLayout:UICollectionViewFlowLayout = { // cards list flowlayout 
        let  layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:50, height:50)
        return layout
    }()
    
    static var wheelLayout:DSCircularLayout = { // cards list flowlayout
        let  layout = DSCircularLayout.init()
        layout.initWithCentre(CGPoint.init(x: UIScreen.main.bounds.size.width / 2.0, y: 97), radius: 75, itemSize: storyItemSize, andAngularSpacing: 0)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.setStartAngle(CGFloat(Double.pi), endAngle: 0)
        return layout
    }()
    static var wheelLayout1:DSCircularLayout = { // cards list flowlayout
        let  layout = DSCircularLayout.init()
        layout.initWithCentre(CGPoint.init(x: UIScreen.main.bounds.size.width / 2.0, y: 97), radius: 75, itemSize: storyItemSize, andAngularSpacing: 0)
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.setStartAngle(CGFloat(Double.pi), endAngle: 0)
        return layout
    }()
}

