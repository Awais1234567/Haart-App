//
//  PushNotificationSender.swift
//  Haart App
//
//  Created by Stone on 26/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import UserNotifications
class PushNotificationSender {
    
    func sendPushNotification(to token: String, title: String, body: String, type:String, id:String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["type" : type, "senderId":id],
                                           "sound":""
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAqaOI9LA:APA91bFsuURq-R0DBZVXgq7fNW0iT1oeTKDlTMMBtO1x0aq7x0b2ERbPH-lK-C_1aaNPhAtaXlnVyejBhf54macgWHFIXSlxJgVjYIUqTcxhpbY_tQ1iJhTvW9A8O6ofix_IkOmGCI5g", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    func sendPushNotification(to token: String, title: String, body: String, imgUrl:String, type:String, id:String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "apns":["fcm_options":["image":imgUrl]],
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["type" : type, "senderId":id],
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAqaOI9LA:APA91bFsuURq-R0DBZVXgq7fNW0iT1oeTKDlTMMBtO1x0aq7x0b2ERbPH-lK-C_1aaNPhAtaXlnVyejBhf54macgWHFIXSlxJgVjYIUqTcxhpbY_tQ1iJhTvW9A8O6ofix_IkOmGCI5g", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    
    func sendLocalNotification(title: String, body: String, type:String, id:String) {
        //creating the notification content
        let content = UNMutableNotificationContent()
        //adding title, subtitle, body and badge
        content.title = title
   //     content.subtitle = "iOS Development is fun"
        content.body = body
        
        content.userInfo = ["type":type,"senderId":id]
        content.badge = content.badge ?? 0 + 1 as NSNumber
        content.sound =  UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "Chime.caf"))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
