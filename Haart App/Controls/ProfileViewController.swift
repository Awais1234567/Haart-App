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
import Quickblox
import QuickbloxWebRTC
import PushKit
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore
import FirebaseDynamicLinks

class ProfileViewController: AbstractControl,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, IGAddStoryCellDelegate {
   
    var lightBoxImagesArr = [LightboxImage]()
    var shouldFetchImagesArr = true
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
    
    var _storiesView:IGHomeView!
    private var isUpdatedPayload = true
    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    private weak var session: QBRTCSession?
    private var sessionID: String?
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    lazy private var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    private var callUUID: UUID?
    private var answerTimer: Timer?
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
        self.view.backgroundColor = UIColor.init(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        gallaryCollectionView.register(UINib(nibName: "GallaryCell", bundle: nil), forCellWithReuseIdentifier: "GallaryCell")
        
        profileImgView.layer.borderColor = UIColor.white.cgColor
        profileImgView.layer.borderWidth = 2
        
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Filter")!], rightImage: [ UIImage.init(named: "Chat")!])
        grayView.grayViewRadiousBottm(value:36)
        
        QBRTCClient.instance().add(self)
               
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            else {
                cell.gallaryImgView.contentMode = .scaleAspectFill
                if(indexPath.row < galleryItemsArr.count) {
                    cell.gallaryImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    cell.gallaryImgView.sd_setImage(with: URL(string:galleryItemsArr[indexPath.row]["url"] as? String ?? "" ), placeholderImage: nil)
                }
                else {
                    cell.gallaryImgView.image = nil
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
                vc.currentUserProfileImage = self.profileImgView.image
                UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
            }           
        default:
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "BioViewController")
            self.present(viewController, animated: true, completion: nil)
            
           print("clicked")
        }
        
    }

    @IBAction func messageBtnPressed(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            let vc = ChannelsViewController(currentUser: user)
            let controller = UINavigationController.init(rootViewController: vc)
            controller.modalPresentationStyle = .overFullScreen
            vc.currentUserProfileImage = self.profileImgView.image
            UIApplication.rootViewController.present(controller, animated: true, completion: nil)
        }
    }
    
}


extension ProfileViewController:AddPostViewControllerDelegate {
    func didSelectMedia(image: UIImage?, video: Any?, caption: String?) {
        if(image != nil) {
            SVProgressHUD.show()
            self.uploadImage(image!, "galleryImages", completion: { (url) in
                SVProgressHUD.dismiss()
                self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"image","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])
                self.gallaryCollectionView.reloadData()
                self.updateGalleryPics()
            })
        }
    }
    
    func addMedia() {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                picker.dismiss(animated: false, completion: {
                    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddPostViewController") as! AddPostViewController
                    vc.selectedImage = photo.image
                    vc.delegate = self
                    UIApplication.visibleViewController.present(HaartNavBarController.init(rootViewController: vc), animated: true, completion: nil)
                })
            }
            else {
               picker.dismiss(animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
    }
    
    func updateGalleryPics() {
        SVProgressHUD.show()
        self.userDocument!.reference.updateData(["galleryPics":galleryItemsArr, "fcmToken":AppSettings.deviceToken], completion: { (error) in
            SVProgressHUD.dismiss()
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
        })
    }
    
    private func uploadImage(_ image: UIImage,_ folderName:String, completion: @escaping (URL?) -> Void) {
        
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
    
    // MARK: - GET DOWNLOAD URL
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        storage.child(path).downloadURL(completion: completion)
    }
    
}
extension ProfileViewController: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let voipToken = registry.pushToken(for: .voIP) else {
            return
        }
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipToken

        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[ProfileViewController] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[ProfileViewController] Create Subscription request - Error")
        })
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            debugPrint("[ProfileViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[ProfileViewController] Unregister Subscription request - Error")
        })
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {


        //in case of bad internet we check how long the VOIP Push was delivered for call(1-1)
        //if time delivery is more than “answerTimeInterval” - return
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            if let timeStampString = payload.dictionaryPayload["timestamp"] as? String,
                let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String {
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")
                if opponentsIDsArray.count == 2 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let startCallDate = formatter.date(from: timeStampString) {
                        if Date().timeIntervalSince(startCallDate) > QBRTCConfig.answerTimeInterval() {
                            debugPrint("[UsersViewController] timeIntervalSinceStartCall > QBRTCConfig.answerTimeInterval")
                            return
                        }
                    }
                }
            }
        }

        let application = UIApplication.shared
        if type == .voIP,
            payload.dictionaryPayload[UsersConstant.voipEvent] != nil,
            application.applicationState == .background {
            var opponentsIDs: [String]? = nil
            var opponentsNumberIDs: [NSNumber] = []
            var opponentsNamesString = "incoming call. Connecting..."
            var sessionID: String? = nil
            var callUUID = UUID()
            var sessionConferenceType = QBRTCConferenceType.audio
            self.isUpdatedPayload = false

            if let opponentsIDsString = payload.dictionaryPayload["opponentsIDs"] as? String,
                let allOpponentsNamesString = payload.dictionaryPayload["contactIdentifier"] as? String,
                let sessionIDString = payload.dictionaryPayload["sessionID"] as? String,
                let callUUIDPayload = UUID(uuidString: sessionIDString) {
                self.isUpdatedPayload = true
                self.sessionID = sessionIDString
                sessionID = sessionIDString
                callUUID = callUUIDPayload
                if let conferenceTypeString = payload.dictionaryPayload["conferenceType"] as? String {
                    sessionConferenceType = conferenceTypeString == "1" ? QBRTCConferenceType.video : QBRTCConferenceType.audio
                }

                let profile = QuickBloxProfile()
                guard profile.isFull == true else {
                    return
                }
                let opponentsIDsArray = opponentsIDsString.components(separatedBy: ",")

                var opponentsNumberIDsArray = opponentsIDsArray.compactMap({NSNumber(value: Int($0)!)})
                var allOpponentsNamesArray = allOpponentsNamesString.components(separatedBy: ",")
                for i in 0...opponentsNumberIDsArray.count - 1 {
                    if opponentsNumberIDsArray[i].uintValue == profile.ID {
                        opponentsNumberIDsArray.remove(at: i)
                        allOpponentsNamesArray.remove(at: i)
                        break
                    }
                }
                opponentsNumberIDs = opponentsNumberIDsArray
                opponentsIDs = opponentsNumberIDs.compactMap({ $0.stringValue })
                opponentsNamesString = allOpponentsNamesArray.joined(separator: ", ")
            }

            let fetchUsersCompletion = { [weak self] (usersIDs: [String]?) -> Void in
                if let opponentsIDs = usersIDs {
                    QBRequest.users(withIDs: opponentsIDs, page: nil, successBlock: { [weak self] (respose, page, users) in
                        if users.isEmpty == false {
                            //self?.dataSource.update(users: users)
                        }
                    }) { (response) in
                        debugPrint("[UsersViewController] error fetch usersWithIDs")
                    }
                }
            }

            self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
            CallKitManager.instance.reportIncomingCall(withUserIDs: opponentsNumberIDs,
                                                       outCallerName: opponentsNamesString,
                                                       session: nil,
                                                       sessionID: sessionID,
                                                       sessionConferenceType: sessionConferenceType,
                                                       uuid: callUUID,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }

                                                        if let session = self.session {
                                                            if isAccept == true {
                                                                self.openCall(withSession: session,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[UsersViewController]  onAcceptAction")
                                                            } else {
                                                                session.rejectCall(["reject": "busy"])
                                                                debugPrint("[UsersViewController] endCallAction")
                                                            }
                                                        } else {
                                                            if isAccept == true {
                                                                self.openCall(withSession: nil,
                                                                              uuid: callUUID,
                                                                              sessionConferenceType: sessionConferenceType)
                                                                debugPrint("[UsersViewController]  onAcceptAction")
                                                            } else {

                                                                debugPrint("[UsersViewController] endCallAction")
                                                            }
                                                            self.setupAnswerTimerWithTimeInterval(UsersConstant.answerInterval)
                                                            self.prepareBackgroundTask()
                                                        }
                                                        completion()

                }, completion: { (isOpen) in
                    self.prepareBackgroundTask()
                    self.setupAnswerTimerWithTimeInterval(QBRTCConfig.answerTimeInterval())
                    if QBChat.instance.isConnected == false {
                        self.connectToChat { (error) in
                            if error == nil {
                                fetchUsersCompletion(opponentsIDs)
                            }
                        }
                    } else {
                        fetchUsersCompletion(opponentsIDs)
                    }
                    debugPrint("[UsersViewController] callKit did presented")
            })
        }
    }

    private func prepareBackgroundTask() {
        let application = UIApplication.shared
        if application.applicationState == .background && self.backgroundTask == .invalid {
            self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
                application.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            })
        }
    }

    private func setupAnswerTimerWithTimeInterval(_ timeInterval: TimeInterval) {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }

        self.answerTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(endCallByTimer),
                                                userInfo: nil,
                                                repeats: false)
    }

    private func invalidateAnswerTimer() {
        if self.answerTimer != nil {
            self.answerTimer?.invalidate()
            self.answerTimer = nil
        }
    }

    private func showAlertView(message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: UsersAlertConstant.okAction, style: .default,
                                                handler: nil))
        present(alertController, animated: true)
    }

    @objc private func endCallByTimer() {
        invalidateAnswerTimer()

        if let endCall = CallKitManager.instance.currentCall() {
            CallKitManager.instance.endCall(with: endCall.uuid) {
                debugPrint("[UsersViewController] endCall sessionDidClose")
            }
        }
        prepareCloseCall()
    }


}
// MARK: - QBRTCClientDelegate
extension ProfileViewController: QBRTCClientDelegate {
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false,
            let sessionID = self.sessionID,
            sessionID == session.id,
            session.initiatorID == userID || isUpdatedPayload == false {
            CallKitManager.instance.endCall(with: callUUID)
            prepareCloseCall()
        }
    }

    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        invalidateAnswerTimer()

        self.session = session

        if let currentCall = CallKitManager.instance.currentCall() {
            //open by VOIP Push

            CallKitManager.instance.setupSession(session)
            if currentCall.status == .ended {
                CallKitManager.instance.setupSession(session)
                CallKitManager.instance.endCall(with: currentCall.uuid)
                session.rejectCall(["reject": "busy"])
                prepareCloseCall()
                } else {
                var opponentIDs = [session.initiatorID]
                let profile = QuickBloxProfile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }

                prepareCallerNameForOpponentIDs(opponentIDs) { (callerName) in
                    CallKitManager.instance.updateIncomingCall(withUserIDs: session.opponentsIDs,
                                                               outCallerName: callerName,
                                                               session: session,
                                                               uuid: currentCall.uuid)
                }
            }
        } else {
            //open by call

            if let uuid = UUID(uuidString: session.id) {
                callUUID = uuid
                sessionID = session.id

                var opponentIDs = [session.initiatorID]
                let profile = QuickBloxProfile()
                guard profile.isFull == true else {
                    return
                }
                for userID in session.opponentsIDs {
                    if userID.uintValue != profile.ID {
                        opponentIDs.append(userID)
                    }
                }

                prepareCallerNameForOpponentIDs(opponentIDs) { [weak self] (callerName) in
                    self?.reportIncomingCall(withUserIDs: opponentIDs,
                                             outCallerName: callerName,
                                             session: session,
                                             uuid: uuid)
                }
            }
        }
    }

    private func prepareCallerNameForOpponentIDs(_ opponentIDs: [NSNumber], completion: @escaping (String) -> Void)  {
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [String]()
        for userID in opponentIDs {

            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID.stringValue)
            }
        }

        if newUsers.isEmpty == false {

            QBRequest.users(withIDs: newUsers, page: nil, successBlock: { [weak self] (respose, page, users) in
                if users.isEmpty == false {
                    self?.dataSource.update(users: users)
                    for user in users {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    }
                    callerName = opponentNames.joined(separator: ", ")
                    completion(callerName)
                }
            }) { (respose) in
                for userID in newUsers {
                    opponentNames.append(userID)
                }
                callerName = opponentNames.joined(separator: ", ")
                completion(callerName)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            completion(callerName)
        }
    }

    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       sessionID: session.id,
                                                       sessionConferenceType: session.conferenceType,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] (isAccept) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        if isAccept == true {
                                                            self.openCall(withSession: session, uuid: uuid, sessionConferenceType: session.conferenceType)
                                                        } else {
                                                            debugPrint("[UsersViewController] endCall reportIncomingCall")
                                                        }

                }, completion: { (isOpen) in
                    debugPrint("[UsersViewController] callKit did presented")
            })
        } else {

        }
    }

    private func openCall(withSession session: QBRTCSession?, uuid: UUID, sessionConferenceType: QBRTCConferenceType) {
        if hasConnectivity() {
            let callViewController = CallViewController()
            if let qbSession = session{
                callViewController.session = qbSession
            }
            callViewController.usersDataSource = self.dataSource
            callViewController.callUUID = uuid
            callViewController.sessionConferenceType = sessionConferenceType
            self.navViewController = UINavigationController(rootViewController: callViewController)
            self.navViewController.modalPresentationStyle = .fullScreen
            self.navViewController.modalTransitionStyle = .crossDissolve
            self.present(self.navViewController, animated: false)
        } else {
            return
        }
    }

    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            if let endedCall = CallKitManager.instance.currentCall() {
                CallKitManager.instance.endCall(with: endedCall.uuid) {
                    debugPrint("[UsersViewController] endCall sessionDidClose")
                }
            }
            prepareCloseCall()
        }
    }

    private func prepareCloseCall() {
        if self.navViewController.presentingViewController?.presentedViewController == self.navViewController {
            self.navViewController.view.isUserInteractionEnabled = false
            self.navViewController.dismiss(animated: false)
        }
        self.callUUID = nil
        self.session = nil
        self.sessionID = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
        //self.setupToolbarButtons()
    }

    private func connectToChat(success:QBChatCompletionBlock? = nil) {
        let profile = QuickBloxProfile()
        guard profile.isFull == true else {
            return
        }

        print(profile)

        QBChat.instance.connect(withUserID: profile.ID,
                                password: profile.password,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            self.logoutAction()
                                        } else {
                                            debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                                        }
                                        success?(error)
                                    } else {
                                        success?(nil)
                                        //did Login action
                                        SVProgressHUD.dismiss()
                                    }
        })
    }
    
    private func hasConnectivity() -> Bool {
        let status = QuickbloxReachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            //showAlertView(message: "Please check your Internet connection")
            print("Please check your Internet connection")
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall func hasConnectivity")
                }
            }
            return false
        }
        return true
    }
}
// MARK: - SettingsViewControllerDelegate
extension ProfileViewController: SettingsViewControllerDelegate {
    func settingsViewController(_ vc: SessionSettingsViewController, didPressLogout sender: Any) {
        logoutAction()
    }

    private func logoutAction() {
        if QBChat.instance.isConnected == false {
            SVProgressHUD.showError(withStatus: "Error")
            return
        }
        SVProgressHUD.show(withStatus: UsersAlertConstant.logout)
        SVProgressHUD.setDefaultMaskType(.clear)

        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        let uuidString = identifierForVendor.uuidString
        #if targetEnvironment(simulator)
        disconnectUser()
        #else
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in

            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
                        subscriptionsUIUD == uuidString,
                        subscription.notificationChannel == .APNSVOIP {
                        self.unregisterSubscription(forUniqueDeviceIdentifier: uuidString)
                        return
                    }
                }
            }
            self.disconnectUser()

        }) { response in
            if response.status.rawValue == 404 {
                self.disconnectUser()
            }
        }
        #endif
    }

    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            self.logOut()
        })
    }

    private func unregisterSubscription(forUniqueDeviceIdentifier uuidString: String) {
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            self.disconnectUser()
        }, errorBlock: { error in
            if let error = error.error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
        })
    }

    private func logOut() {
        QBRequest.logOut(successBlock: { [weak self] response in
            //ClearProfile
            QuickBloxProfile.clearProfile()
            SVProgressHUD.dismiss()
            //Dismiss Settings view controller
            self?.dismiss(animated: false)

            DispatchQueue.main.async(execute: {
                self?.navigationController?.popToRootViewController(animated: false)
            })
        }) { response in
            debugPrint("QBRequest.logOut error\(response)")
        }
    }
}



