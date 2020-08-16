//
//  LikeService.swift
//  Haart App
//
//  Created by OBS on 30/07/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import FirebaseDatabase

//struct LikeService {
//
//    static func create(for post: Post, success: @escaping (Bool) -> Void) {
//        // 1
//        guard let key = post.key else {
//            return success(false)
//        }
//
//        // 2
//        let currentUID = User.current.uid
//
//           let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
//         likesRef.setValue(true) { (error, _) in
//             if let error = error {
//                 assertionFailure(error.localizedDescription)
//                 return success(false)
//             }
//
//             return success(true)
//         }
//    }
//
//    static func delete(for post: Post, success: @escaping (Bool) -> Void) {
//        guard let key = post.key else {
//            return success(false)
//        }
//
//        let currentUID = User.current.uid
//
//        let likesRef = Database.database().reference().child("postLikes").child(key).child(currentUID)
//        likesRef.setValue(nil) { (error, _) in
//            if let error = error {
//                assertionFailure(error.localizedDescription)
//                return success(false)
//            }
//
//            return success(true)
//        }
//    }
//
//}