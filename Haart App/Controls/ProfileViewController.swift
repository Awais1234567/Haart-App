//
//  ProfileViewController.swift
//  Haart App
//
//  Created by Stone on 26/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import SDWebImage
import YPImagePicker
import Firebase
import Lightbox
import FirebaseStorage
import AVFoundation
class ProfileViewController: AbstractControl,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, IGAddStoryCellDelegate {
   
    var lightBoxImagesArr = [LightboxImage]()
    var shouldFetchImagesArr = true
    let defaults = UserDefaults.standard
    private let storage = Storage.storage().reference()
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet var storiesViewContainer: UIView!
    private var viewModel: IGHomeViewModel = IGHomeViewModel()

    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var gallaryCollectionView: UICollectionView!
    var galleryItemsArr:[[String:Any]] = [["void":""]]
    var galleryVideoArr:[[String:Any]] = [["void":""]]
    var playerLayer = AVPlayerLayer(player: nil)
    var player = AVPlayer()
    
    var _storiesView:IGHomeView!
    //MARK: - Overridden functions
    override func loadView() {
        super.loadView()
        
         _storiesView = IGHomeView(frame: CGRect.init(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 195))
        storiesViewContainer.addSubview(_storiesView)
        _storiesView.backgroundColor = .clear
        _storiesView.clipsToBounds = false
        _storiesView.collectionView.setCollectionViewLayout(FlowLayout.wheelLayout, animated: false)
        _storiesView.collectionView.delegate = self
        _storiesView.collectionView.backgroundColor = .clear
        _storiesView.collectionView.bounces = false
        _storiesView.collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        msgBtn.backgroundColor = .red
       // _storiesView.backgroundColor = .black
    }
    
    //MARK: - Private functions
    @objc private func clearImageCache() {
        IGCache.shared.removeAllObjects()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.setValue(self.user.uid, forKey: "User_ID")
        self.view.backgroundColor = UIColor.init(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        gallaryCollectionView.register(UINib(nibName: "GallaryCell", bundle: nil), forCellWithReuseIdentifier: "GallaryCell")
        
        profileImgView.layer.borderColor = UIColor.white.cgColor
        profileImgView.layer.borderWidth = 2
        
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Filter")!], rightImage: [ UIImage.init(named: "Chat")!])
        grayView.grayViewRadiousBottm(value:36)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        getData()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            PushNotificationSender().sendLocalNotification( title: "tile", body: "body", type: "tpe", id: "id")
//
//        }
    }
    
    func getData() {
        if(self.userDocument == nil) {
            SVProgressHUD.show()
        }
        var storiesArr = [[String:Any]]()
        let ref = db.collection("users").whereField("userId", isEqualTo: self.user.uid)
        ref.getDocuments { (snapshot, error) in
            if let e = error {
                SVProgressHUD.dismiss()
                UIApplication.showMessageWith(e.localizedDescription )
                return
            }
            if(self.userDocument == nil) {
                SVProgressHUD.dismiss()
            }
            if(snapshot?.documents.count == 0) {
            }
            else {
                for i in 0..<snapshot!.documents.count {
                    if(snapshot!.documents[i].data()["userId"] as! String == self.user.uid) {// current user
                        self.userDocument = snapshot?.documents[i]
                        AppSettings.currentUserSnapshot = self.userDocument
                        if let userStories = snapshot?.documents[i].data()["stories"] as? [String:Any] {
                            storiesArr.insert(userStories, at: 0)
                        }
                        
                        if let imgsArr = (self.userDocument?.data()["bioPics"] as? [String]) {
                            if(imgsArr.count > 0) {
                                self.profileImgView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                                self.profileImgView.sd_setImage(with: URL(string:imgsArr[0]), placeholderImage: nil)
                            }
                        }
                        
                        self.nameLbl.text = self.userDocument?.data()["fullName"] as? String
                        self.userNameLbl.text = self.userDocument?.data()["userName"] as? String
                        self.descLbl.text = self.userDocument?.data()["bio"] as? String
                        self.followersCountLbl.text = (self.userDocument?.data()["followedBy"] as? [String] ?? [String]()).count.string
                        self.followingCountLbl.text = (self.userDocument?.data()["followed"] as? [String] ?? [String]()).count.string
                        
                     //   if(self.shouldFetchImagesArr == true) { //do not update agaib and gain because already updated
                 
                        self.galleryItemsArr = self.userDocument?.data()["galleryPics"] as? [[String:Any]] ?? [["void":"","time":1]]
                            var tempArr = self.userDocument?.data()["galleryPics"] as? [[String:String]] ?? [["":""]]
                            tempArr.removeFirst()
                            self.lightBoxImagesArr.removeAll()
                            for item in tempArr {
                                self.lightBoxImagesArr.append(LightboxImage(imageURL: URL(string: item["url"] ?? "")!))
                            }
                      //  }
                        self.shouldFetchImagesArr = false
                        self.gallaryCollectionView.reloadData()
                        break
                    }
                }

                
                print(storiesArr)
                let storiesController = StoriesController()
                storiesController.currentUserDocument = self.userDocument
                self.viewModel.stories = storiesController.returnAndSetOwnValidStories(storiesArr: storiesArr)
                self._storiesView.collectionView.reloadData()

            }
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
        self.present(viewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView.isEqual(gallaryCollectionView)) {
            var cellSize: CGSize = collectionView.bounds.size
           // cellSize.width = (collectionView.bounds.size.width - 60) / 3
            cellSize.width = (collectionView.bounds.size.width - 4) / 3
            cellSize.height = cellSize.width
            return cellSize
        }
        return indexPath.row == 0 ? storyItemSize : storyItemSize
    }
    
    override func leftBarBtnClicked(sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FilterViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.isEqual(gallaryCollectionView)) {
            return (self.galleryItemsArr.count > 9) ? self.galleryItemsArr.count : 9
        }
        let count = viewModel.numberOfItemsInSection(section)
        print(count)
        return count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView.isEqual(gallaryCollectionView)) {
            let cell : GallaryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GallaryCell", for: indexPath as IndexPath) as! GallaryCell
            if (indexPath.row == 0) {
                cell.gallaryImgView.contentMode = .center
                cell.gallaryImgView.image = UIImage.init(named: "Camera_Big_Red")
            }
            else if(indexPath.row != 0){
                cell.gallaryImgView.contentMode = .scaleAspectFill
                if(indexPath.row < galleryItemsArr.count) {
                    if(galleryItemsArr[indexPath.row]["type"] as! String == "video"){
                        cell.VideoView.isHidden = false
                        cell.VideoView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        let videoURL = NSURL(string: galleryItemsArr[indexPath.row]["url"] as! String)
                         player = AVPlayer(url: videoURL! as URL)
                        NotificationCenter.default.addObserver(self,
                        selector: #selector(playerItemDidReachEnd),
                          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                          object: player.currentItem)
                        playerLayer = AVPlayerLayer(player: player)
                        playerLayer.videoGravity = .resizeAspectFill
                        playerLayer.frame = cell.VideoView.bounds
                        cell.VideoView.layer.addSublayer(playerLayer)
                        player.play()
                        
                    }else if(galleryItemsArr[indexPath.row]["type"] as! String == "image"){
                    cell.gallaryImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    cell.gallaryImgView.sd_setImage(with: URL(string:galleryItemsArr[indexPath.row]["url"] as? String ?? "" ), placeholderImage: nil)
                    }
                }
                else {
                    cell.gallaryImgView.image = nil
                    cell.VideoView.isHidden = true
                }
            }
            //cell.gallaryImgView.superview!.layer.cornerRadius = 10.0
            //cell.gallaryImgView.superview!.clipsToBounds = true
            return cell
        }
        storyItemSize = CGSize.init(width: 40, height: 40)
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier, for: indexPath) as? IGAddStoryCell else { fatalError() }
            cell.userDetails = ("Your Story","")
            cell.delegate = self

            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,for: indexPath) as? IGStoryListCell else { fatalError() }
            let story = viewModel.cellForItemAt(indexPath: indexPath)
            cell.story = story
            
            return cell
        }
    }
    
    func addStoryButtonPressed() {
        let storiesController = StoriesController()
        storiesController.currentUserDocument = userDocument
        storiesController.addStory()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.isEqual(gallaryCollectionView)) {
            if indexPath.row == 0 {
                addMedia()
            }
            else {
                if(indexPath.row < galleryItemsArr.count) {
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FeedControl") as! FeedControl
                    vc.image = profileImgView.image
                    vc.feedsArr = galleryItemsArr
                    self.navigationController?.pushViewController(vc, animated: true)
                }
               
               /* let controller = LightboxController.init(images: lightBoxImagesArr, startIndex: indexPath.row - 1)
                print(lightBoxImagesArr)
//                // Set delegates.
//                controller.pageDelegate = self
//                controller.dismissalDelegate = self
//
//                // Use dynamic background.
//                controller.dynamicBackground = true
//
                // Present your controller.
                present(controller, animated: true, completion: nil)*/
            }
            return
        }
        
        if indexPath.row == 0 {
           addStoryButtonPressed()
            DispatchQueue.main.async {
//                if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
//                    if(self.viewModel.cellForItemAtActual(indexPath: indexPath)?.snaps.count ?? 0 > 0) {
//                        let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row)
//                        self.present(storyPreviewScene, animated: true, completion: nil)
//                    }
//                }
            }
        } else {
            DispatchQueue.main.async {
                if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
                    let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row - 1)
                    self.present(storyPreviewScene, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc override func rightBarBtnClicked(sender:UIButton) {
        
        switch sender.tag {
        case 1:
            if let user = Auth.auth().currentUser {
                let vc = ChannelsViewController(currentUser: user)
                let controller = UINavigationController.init(rootViewController: vc)
                controller.modalPresentationStyle = .overFullScreen
                UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
            }           
        default:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
            self.present(viewController, animated: true, completion: nil)
            
           print("clicked")
        }
        
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
                     player.seek(to: CMTime.zero)
                    player.play()
                 }
    
    @IBAction func messageBtnPressed(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            let vc = ChannelsViewController(currentUser: user)
            let controller = UINavigationController.init(rootViewController: vc)
            controller.modalPresentationStyle = .overFullScreen
            UIApplication.rootViewController.present(controller, animated: true, completion: nil)
        }
    }
    
    func didSelectMedia2(image: UIImage?, video: YPMediaVideo?, caption: String?) {
           if(image != nil) {
               print("add function called")
               SVProgressHUD.show()
               self.uploadImage(image!, "galleryImages", completion: { (url) in
                   SVProgressHUD.dismiss()
                   self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"image","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])
                   self.gallaryCollectionView.reloadData()
                   self.updateGalleryPics()
               })
           }
           if(video != nil){
                         SVProgressHUD.show()
           print("upload Video Called")
               self.uploadVideo(video!, "galleryImages", completion: {(url) in
                      SVProgressHUD.dismiss()
               self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"video","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])
                                 self.gallaryCollectionView.reloadData()
                              self.updateGalleryPics()
                   
                   
               })
               
           }
           
           
       }
    
}


extension ProfileViewController:AddPostViewControllerDelegate {
    
    func didSelectMedia(image: UIImage?, video: YPMediaVideo?, caption: String?) {
   
            print("add function called")
            SVProgressHUD.show()
            self.uploadImage(image!, "galleryImages", completion: { (url) in
                SVProgressHUD.dismiss()
                self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"image","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])
                self.gallaryCollectionView.reloadData()
                self.updateGalleryPics()
            })
        
        if(video != nil){
                      SVProgressHUD.show()
        print("upload Video Called")
            self.uploadVideo(video!, "galleryImages", completion: {(url) in
                   SVProgressHUD.dismiss()
            self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"video","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])
                              self.gallaryCollectionView.reloadData()
                           self.updateGalleryPics()


            })

        }
        
        
    }
    
    func addMedia(){
        print("camera tapped")
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.modalPresentationStyle = .fullScreen
                UIApplication.visibleViewController.present(vc, animated: true)
        }

        
    
//    func addMedia() {
//        var config = YPImagePickerConfiguration()
//        config.video.compression = AVAssetExportPresetMediumQuality
//        config.showsPhotoFilters = false
//        config.showsCrop = YPCropType.rectangle(ratio: Double(UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height))
//
//        config.library.mediaType = .photoAndVideo
//        config.showsPhotoFilters = true
//        //config.filters
//        config.video.recordingTimeLimit = 30.0
//        config.showsVideoTrimmer = true
//        config.screens = [.library,.photo]
//        //config.video.libraryTimeLimit = 30.0
//        config.library.defaultMultipleSelection = true
//        config.video.minimumTimeLimit = 3.0
//        config.video.trimmerMaxDuration = 30.0
//        config.video.trimmerMinDuration = 3.0
//        config.library.maxNumberOfItems = 4
//        let picker = YPImagePicker(configuration: config)
//        picker.didFinishPicking { [unowned picker] items, _ in
//            if let photo = items.singlePhoto {
//                picker.dismiss(animated: false, completion: {
//                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddPostViewController") as! AddPostViewController
//                    vc.selectedImage = photo.image
//                    vc.delegate = self
//                    UIApplication.visibleViewController.present(HaartNavBarController.init(rootViewController: vc), animated: true, completion: nil)
//                })
//            } else  if let video = items.singleVideo{
//                        picker.dismiss(animated: false, completion: {
//                            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddPostViewController") as! AddPostViewController
////
//                            vc.selectedVideoThumb = video.thumbnail
//                            vc.selectedVideoUrl = video.url
//                            vc.delegate = self
//                            UIApplication.visibleViewController.present(HaartNavBarController.init(rootViewController: vc), animated: true, completion: nil)
//                        })
//                    }
//            else {
//               picker.dismiss(animated: true, completion: nil)
//            }
//        }
//        present(picker, animated: true, completion: nil)
//    }
//
    func updateGalleryPics() {
        SVProgressHUD.show()
        self.userDocument!.reference.updateData(["galleryPics":galleryItemsArr, "fcmToken":AppSettings.deviceToken], completion: { (error) in
            SVProgressHUD.dismiss()
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
        })
    }
//    func updateGalleryVids() {
//         SVProgressHUD.show()
//         self.userDocument!.reference.updateData(["galleryVideos":galleryVideoArr, "fcmToken":AppSettings.deviceToken], completion: { (error) in
//             SVProgressHUD.dismiss()
//             if let e = error {
//                 UIApplication.showMessageWith(e.localizedDescription)
//             }
//         })
//     }
    
 func uploadImage(_ image: UIImage,_ folderName:String, completion: @escaping (URL?) -> Void) {
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(user.uid).child(folderName).child(imageName).putData(data, metadata: metadata) { meta, error in
            if let error1 = error {
                UIApplication.showMessageWith(error1.localizedDescription)
                SVProgressHUD.dismiss()
                print(error1.localizedDescription)
                return
            }
            self.getDownloadURL(from: metadata.path!, completion: { (url, error) in
                if let error1 = error {
                    UIApplication.showMessageWith(error1.localizedDescription)
                    SVProgressHUD.dismiss()
                    print(error1.localizedDescription)
                    return
                }
                completion(url)
            })
        }
    }
    
    func uploadVideo(_ video: YPMediaVideo,_ folderName:String, completion: @escaping (URL?) -> Void) {
        video.fetchData { (data) in
            let metadata = StorageMetadata()
            metadata.contentType = "video/mov"
            
            let videoName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
            storage.child(self.user.uid).child(folderName).child(videoName).putFile(from: video.url, metadata: nil, completion: { (meta, error) in
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
    
}

