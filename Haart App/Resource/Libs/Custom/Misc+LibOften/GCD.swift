//
//  GCD.swift
//  Reminisce
//
//  Created by Raman on 23/02/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension DispatchQueue {
    
    class func dispatch_async_main(_ block: @escaping () -> Void) {
        self.main.async(execute: block)
    }
    
    class func dispatch_async_default(_ block: @escaping () -> Void) {
        self.global(qos: .default).async(execute: block)
    }
    
    class func dispatch_sync_main(_ block: @escaping () -> Void) {
        self.main.sync(execute: block)
    }
    
    class func dispatch_main_after(_ delay: Double, block: @escaping () -> Void) {
        self.main.asyncAfter(deadline: .now() + delay, execute: block)
    }
    
    class func dispatch_default_after(_ delay: Double, block: @escaping () -> Void) {
        self.global(qos: .default).asyncAfter(deadline:  .now() + delay, execute: block)
    }

    class func dispatch_sync_main_safely(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            dispatch_sync_main(block)
        }
    }
    
}


