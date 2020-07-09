//
//  String.swift
//  Dropneed
//
//  Created by Raman on 19/04/17.
//  Copyright © 2017 Raman. All rights reserved.
//

import UIKit

extension String {

    var isEmpty: Bool {
        return self.count == 0 && trimmingCharacters(in: .whitespaces).count == 0
    }
    
   /* var validPhoneNo: Bool {
        var length = 11
        if LocalStore.shared.country.countryId == 99 {
            length = 10
        }
        return characters.count <= length
    }*/
    
    var containCharacters: Bool {
        let letters = NSCharacterSet.letters
        return self.rangeOfCharacter(from: letters.inverted) != nil
    }
    
    var float: Float {
        return Float(self)!
    }
    
    var int: Int {
        return Int(self)!
    }
    
    var length: Int {
        return self.count
    }
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<(len){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
}


