//
//  UIRefreshControl.swift
//  Dropneed
//
//  Created by Raman on 31/03/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension UIRefreshControl {

    func endRefreshingIfNeeded() {
        if isRefreshing {
            endRefreshing()
        }
    }
}


