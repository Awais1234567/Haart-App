//
//  UICollectionView_Ext.swift
//  CardsApp
//
//  Created by Raman on 23/11/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    //MARK: Scroll to index path (if cell width == screen width)
    var currentRow:Int {
        return returnCurrentRow()
    }
    
    var isLastRow:Bool {
        if self.contentSize.width <= self.contentOffset.x + UIScreen.main.bounds.size.width {
            return true
        }
        return false
    }
    
    var isFirstRow:Bool {
        if self.contentOffset.x == 0 {
            return true
        }
        return false
    }
    
    func returnCurrentRow() -> Int {
        let currentRow = self.contentOffset.x / UIScreen.main.bounds.size.width
        return Int(currentRow)
    }
    
    func scrollToPreviousIndexPath() {
        let currentRow = self.currentRow
        if currentRow == 0 {
            return
        }
        let previousIndexPath = IndexPath.init(row: currentRow - 1, section: 0)
        self.scrollTo(indexPath: previousIndexPath)
    }
    
    func scrollToNextIndexPath() {
        let currentRow = self.currentRow
        if self.contentSize.width <= self.contentOffset.x + UIScreen.main.bounds.size.width {
            return
        }
        let nextIndexPath = IndexPath.init(row: currentRow + 1, section: 0)
        self.scrollTo(indexPath: nextIndexPath)
    }
    
    func scrollTo(indexPath:IndexPath) {
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}
