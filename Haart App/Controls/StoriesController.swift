//
//  StoriesController.swift
//  Haart App
//
//  Created by Stone on 19/04/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import YPImagePicker
import SVProgressHUD
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore
import FirebaseDynamicLinks
import FirebaseAuth
import FirebaseMessaging
import AVFoundation
class StoriesController:UIViewController {
    let storage = Storage.storage().reference()
    var currentUser = Auth.auth().currentUser
    var currentUserDocument:QueryDocumentSnapshot?
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    var storiesArr = [[String:Any]]()
    
    func addStory() {
        var config = YPImagePickerConfiguration()
        config.video.compression = AVAssetExportPresetMediumQuality
        config.showsPhotoFilters = false
        config.showsCrop = YPCropType.rectangle(ratio: Double(UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height))
        
        config.library.mediaType = .photoAndVideo
        config.showsPhotoFilters = true
        //config.filters
        config.video.recordingTimeLimit = 30.0
        config.showsVideoTrimmer = true
        config.screens = [.library, .video, .photo]
        //config.video.libraryTimeLimit = 30.0
        config.library.defaultMultipleSelection = true
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 30.0
        config.video.trimmerMinDuration = 3.0
        config.library.maxNumberOfItems = 4
        let picker = YPImagePicker(configuration: config)

        picker.didFinishPicking { [unowned picker] items, _ in
            SVProgressHUD.show()
            var profilePicUrl = ""
            if let imgsArr = (self.currentUserDocument?.data()["bioPics"] as? [String]) {
                if(imgsArr.count > 0) {
                    profilePicUrl = imgsArr[0]
                }
            }
            var oldStories:[String:Any] = self.currentUserDocument?.data()["stories"] as? [String:Any] ?? [String:Any]()
            
            var snaps = oldStories["snaps"] as? [[String:Any]] ?? [[String:Any]]()
            
            let user = ["id":self.currentUser!.uid,"name":self.currentUserDocument?["fullName"] as! String,"picture":profilePicUrl]
            
            if let photo = items.singlePhoto {
                
                self.uploadImage(photo.image, "stories", completion: { (url) in
                    let story = ["id": "".randomStringWithLength(len: 16),
                                 "mime_type": "image",
                                 "url": url?.absoluteString ?? "",
                                 "last_updated": Int(Date.init().timeIntervalSince1970)] as [String : Any]
                    snaps.append(story)
                    let stories = ["id":"ty","last_updated":Int(Date.init().timeIntervalSince1970),"user":user,"snaps_count":snaps.count,"snaps":snaps] as [String : Any]

                    self.currentUserDocument?.reference.updateData(["stories":stories], completion: { (error) in

                    })
                    SVProgressHUD.dismiss()
                })
                picker.dismiss(animated: true, completion: nil)
            }
            else if let video = items.singleVideo {
                self.uploadVideo(video, "stories", completion: { (url) in
                    let story = ["id": "".randomStringWithLength(len: 16),
                                 "mime_type": "video",
                                 "url": url?.absoluteString ?? "",
                                 "last_updated": Int(Date.init().timeIntervalSince1970)] as [String : Any]
                    snaps.append(story)
                    let stories = ["id":"ty","last_updated":Int(Date.init().timeIntervalSince1970),"user":user,"snaps_count":snaps.count,"snaps":snaps] as [String : Any]
                    
                    self.currentUserDocument?.reference.updateData(["stories":stories], completion: { (error) in
                        
                    })
                    SVProgressHUD.dismiss()
                })
                picker.dismiss(animated: true, completion: nil)
            }
            else {
                SVProgressHUD.dismiss()
                picker.dismiss(animated: true, completion: nil)
            }
            
        }
        UIApplication.visibleViewController.present(picker, animated: true, completion: nil)
    }
    private func uploadImage(_ image: UIImage,_ folderName:String, completion: @escaping (URL?) -> Void) {
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(currentUser!.uid).child(folderName).child(imageName).putData(data, metadata: metadata) { meta, error in
            if let error1 = error {
                UIApplication.showMessageWith(error1.localizedDescription)
                print(error1.localizedDescription)
                return
            }
            self.getDownloadURL(from: metadata.path!, completion: { (url, error) in
                if let error1 = error {
                    UIApplication.showMessageWith(error1.localizedDescription)
                    print(error1.localizedDescription)
                    return
                }
                completion(url)
            })
        }
    }
    
    private func uploadVideo(_ video: YPMediaVideo,_ folderName:String, completion: @escaping (URL?) -> Void) {
        video.fetchData { (data) in
            let metadata = StorageMetadata()
            metadata.contentType = "video/mov"
            
            let videoName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
            storage.child(currentUser!.uid).child(folderName).child(videoName).putFile(from: video.url, metadata: nil, completion: { (meta, error) in
                self.getDownloadURL(from: meta?.path ?? "", completion: { (url, error) in
                    if let error1 = error {
                                                UIApplication.showMessageWith(error1.localizedDescription)
                                                print(error1.localizedDescription)
                                                return
                                            }
                                            completion(url)
                })
            })

        }
    }
    
    // MARK: - GET DOWNLOAD URL
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        storage.child(path).downloadURL(completion: completion)
    }

    
    func returnAndSetValidStories(storiesArr:[[String:Any]]) -> IGStories?  {//temporarly delete others expired stories and permanently delete own story (never will show expired stories)
                var validStories = [[String:Any]]()
                for i in 0..<storiesArr.count {
                    var snaps = storiesArr[i]["snaps"] as? Array<[String:Any]> ?? Array<[String:Any]>()
                    let oldSnapsCount = snaps.count
                    snaps.removeAll(where: { (snap) -> Bool in
                        let timeInterval = Double(snap["last_updated"] as! Int)
                        // create NSDate from Double (NSTimeInterval)
                        let myNSDate = Date(timeIntervalSince1970: timeInterval)
                        let hour = myNSDate.getAgoTimeForStories().0
                        return hour >= 24
                    })
                    var userStories = storiesArr[i]
                    userStories["snaps"] = snaps
                    userStories["snaps_count"] = snaps.count
                    let user = storiesArr[i]["user"] as? [String:Any] ?? [String:Any]()
                    let userId = user["id"] as? String ?? ""
                    print(snaps)
                    if(currentUser?.uid == userId && snaps.count != oldSnapsCount) {
                        self.currentUserDocument?.reference.updateData(["stories":userStories], completion: { (error) in
                            print("removed expired stories on server")
                        })
                    }
                    if(snaps.count > 0) {
                       validStories.append(userStories)
                    }
                }
                return getStories(storiesArr: validStories)
    }
    

    func returnAndSetOwnValidStories(storiesArr:[[String:Any]]) -> IGStories?  {//temporarly delete others expired stories and permanently delete own story (never will show expired stories)
        var validStories = [[String:Any]]()
        for i in 0..<storiesArr.count {
            var snaps = storiesArr[i]["snaps"] as? Array<[String:Any]> ?? Array<[String:Any]>()
            let oldSnapsCount = snaps.count
            snaps.removeAll(where: { (snap) -> Bool in
                let timeInterval = Double(snap["last_updated"] as! Int)
                // create NSDate from Double (NSTimeInterval)
                let myNSDate = Date(timeIntervalSince1970: timeInterval)
                let hour = myNSDate.getAgoTimeForStories().0
               // return false
                return hour >= 24
            })
            
            var userStories = storiesArr[i]
            userStories["snaps"] = snaps
            userStories["snaps_count"] = snaps.count
            let user = storiesArr[i]["user"] as? [String:Any] ?? [String:Any]()
            let userId = user["id"] as? String ?? ""
            print(snaps)
            if(currentUser?.uid == userId && snaps.count != oldSnapsCount) {
                self.currentUserDocument?.reference.updateData(["stories":userStories], completion: { (error) in
                    print("removed expired stories on server")
                })
            }
            if(snaps.count > 0 && currentUser?.uid == userId) {
                validStories.append(userStories)
            }
        }
        var datesArr = Array<String>()
        for myStories in validStories {
            for snap in myStories["snaps"] as? Array<[String:Any]> ?? Array<[String:Any]>() {
                let timeInterval = Double(snap["last_updated"] as! Int)
                let myNSDate = Date(timeIntervalSince1970: timeInterval)
                let dateStr = myNSDate.string("dd-MM-yyyy")
                
                if(!datesArr.contains(dateStr)) {
                    datesArr.append(dateStr)
                }
            }
        }
        var myValidStories = [[String:Any]]()
        for date in datesArr {
             for myStories in validStories {
                var stories = myStories
                let snaps = myStories["snaps"] as? Array<[String:Any]> ?? Array<[String:Any]>()
                let filteredSnaps = snaps.filter { (snap) -> Bool in
                    let timeInterval = Double(snap["last_updated"] as! Int)
                    let myNSDate = Date(timeIntervalSince1970: timeInterval)
                    let dateStr = myNSDate.string("dd-MM-yyyy")
                    return dateStr == date
                }
                if(filteredSnaps.count > 0) {
                    stories["snaps"] = filteredSnaps
                    stories["snaps_count"] = filteredSnaps.count
                    myValidStories.append(stories)
                }
            }
        }
        return getStories(storiesArr: myValidStories)
    }
    
    func getStories(storiesArr:[[String : Any]]) -> IGStories? {
        do {
            let allStoriesDic = ["count":storiesArr.count, "stories":storiesArr] as [String : Any]
            print(allStoriesDic)
            return try IGMockLoader.loadAPIResponse(response: allStoriesDic )
        }catch let e as MockLoaderError {
            debugPrint(e.description)
        }catch{
            debugPrint("could not read Mock json file :(")
        }
        return nil
    }
}



