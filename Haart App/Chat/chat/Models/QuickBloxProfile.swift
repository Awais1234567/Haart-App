//
//  QuickBloxProfile.swift
//  Haart App
//
//  Created by Awais Khalid on 24/07/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC
struct UserProfileConstant {
    static let curentProfile = "curentProfile"
}
struct CallConstant {
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let sharingViewControllerIdentifier = "SharingViewController"
    static let refreshTimeInterval: TimeInterval = 1.0
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call. Please, reduce the quality of the video settings", comment: "")
    static let sessionDidClose = NSLocalizedString("Session did close due to time out", comment: "")
}
class QuickBloxProfile: NSObject  {
    
    // MARK: - Public Methods
    class func currentUser() -> QuickBloxUser? {
        guard let current = QuickBloxProfile.loadObject() else {
            return nil
        }
        let user = QuickBloxUser(user: current)
        return user
    }
    
    class func clearProfile() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: UserProfileConstant.curentProfile)
    }
    
    class func synchronize(_ user: QBUUser) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: UserProfileConstant.curentProfile)
    }
    
    class func update(_ user: QBUUser) {
        if let current = QuickBloxProfile.loadObject() {
            if let fullName = user.fullName {
                current.fullName = fullName
            }
            if let login = user.login {
                current.login = login
            }
            if let password = user.password {
                current.password = password
            }
            QuickBloxProfile.synchronize(current)
        } else {
            QuickBloxProfile.synchronize(user)
        }
    }
    
   //MARK: - Internal Class Methods
   private class func loadObject() -> QBUUser? {
        let userDefaults = UserDefaults.standard
        guard let decodedUser  = userDefaults.object(forKey: UserProfileConstant.curentProfile) as? Data,
            let user = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as? QBUUser else {
                return nil
        }
        
        return user
    }
    
    //MARK - Properties
    var isFull: Bool {
        return user != nil
    }
    
    var ID: UInt {
        return user!.id
    }
    
    var login: String {
        return user!.login!
    }
    
    var password: String {
        return user!.password!
    }
    
    var fullName: String {
        return user!.fullName!
    }
    
    var tags: [String]? {
        return user!.tags
    }
    
    private var user: QBUUser? = {
        return QuickBloxProfile.loadObject()
    }()
}



class QuickBloxUser {
    //MARK - Properties
    private var user: QBUUser!
    var connectionState: QBRTCConnectionState = .connecting
    var userName: String {
        return user.fullName ?? CallConstant.unknownUserLabel
    }
    
    var userID: UInt {
        return user.id
    }
    
    var bitrate: Double = 0.0
    
    //MARK: - Life Cycle
    required init(user: QBUUser) {
        self.user = user
    }
}
