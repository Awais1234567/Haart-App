//
//  OthersProfileViewController.swift
//  Haart App
//
//  Created by Stone on 10/05/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//


import UIKit
import SVProgressHUD
import FirebaseAuth
import SDWebImage
import YPImagePicker
import Firebase

class OthersProfileViewController: AbstractControl,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, IGAddStoryCellDelegate {
    
    
    var shouldFetchImagesArr = true
    private let storage = Storage.storage().reference()
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet var storiesViewContainer: UIView!
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var msgBtn: UIButton!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var gallaryCollectionView: UICollectionView!
    var galleryItemsArr = [String]()
    var personId = ""
    var _storiesView:IGHomeView!
    var listType:ListType = .suggested
    var channelReference: Query {
        return db.collection("channels").whereField("userIds", arrayContains: user.uid)
    }
    //MARK: - Overridden functions
    override func loadView() {
        super.loadView()
        
        _storiesView = IGHomeView(frame: CGRect.init(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 195))
        storiesViewContainer.addSubview(_storiesView)
        _storiesView.backgroundColor = .clear
        _storiesView.clipsToBounds = false
        _storiesView.collectionView.setCollectionViewLayout(FlowLayout.wheelLayout1, animated: false)
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
        print(personId)
        self.view.backgroundColor = UIColor.init(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        gallaryCollectionView.register(UINib(nibName: "GallaryCell", bundle: nil), forCellWithReuseIdentifier: "GallaryCell")
        
        profileImgView.layer.borderColor = UIColor.white.cgColor
        profileImgView.layer.borderWidth = 2
        
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: [ UIImage.init(named: "Chat")!])
//        let rect = CGRect(x: 0, y: 0, width: 40, height: 35)
//        let btn = UIButton.init(frame: rect)
//        btn.setImage(UIImage.init(named: "Back")!, for: .normal)
//        btn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        
        grayView.grayViewRadiousBottm(value:36)
       
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
    
    func configFollowBtn() {
        if ((AppSettings.currentUserSnapshot!.data()["followed"] as? Array<String> ?? Array<String>()).contains(personId)) {
            followBtn.setTitle("Unfollow", for: .normal)
            followBtn.backgroundColor = UIColor.init(red: 68/255.0, green: 69/255.0, blue: 70 / 255.0, alpha: 1)
            self.listType = .followed
        }
        else if ((AppSettings.currentUserSnapshot!.data()["requestSent"] as? Array<String> ?? Array<String>()).contains(personId)) {
            followBtn.setTitle("Cancel", for: .normal)
            followBtn.backgroundColor = .red
            self.listType = .pending
            followBtn.tag = 0
        }
        else {
            followBtn.setTitle("Follow", for: .normal)
            followBtn.backgroundColor = .red
            self.listType = .suggested
        }
    }
    
    func getData() {
        if(self.userDocument == nil) {
            SVProgressHUD.show()
        }
        var storiesArr = [[String:Any]]()
        let ref = db.collection("users").whereField("userId", isEqualTo: personId)
        ref.getDocuments { (snapshot, error) in
            if let e = error {
                SVProgressHUD.dismiss()
                UIApplication.showMessageWith(e.localizedDescription )
                return
            }
            if(snapshot?.documents.count == 0) {
            }
            else {
                for i in 0..<snapshot!.documents.count {
                    if(snapshot!.documents[i].data()["userId"] as! String == self.personId) {
                        self.userDocument = snapshot?.documents[i]
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
                        
                        if(self.shouldFetchImagesArr == true) { //do not update agaib and again because already updated
                            self.galleryItemsArr = self.userDocument?.data()["galleryPics"] as? [String] ?? [String]()
                            if(self.galleryItemsArr.count > 0) {
                                self.galleryItemsArr.remove(at: 0)//removing placeholder of camera
                            }
                        }
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
                SVProgressHUD.dismiss()
                self.configFollowBtn()
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
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.isEqual(gallaryCollectionView)) {
            return (self.galleryItemsArr.count > 9) ? self.galleryItemsArr.count : 9
        }
        
        return viewModel.numberOfActualItemsInSection(section)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView.isEqual(gallaryCollectionView)) {
            let cell : GallaryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GallaryCell", for: indexPath as IndexPath) as! GallaryCell
           
                cell.gallaryImgView.contentMode = .scaleAspectFill
                if(indexPath.row < galleryItemsArr.count) {
                    cell.gallaryImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    cell.gallaryImgView.sd_setImage(with: URL(string:galleryItemsArr[indexPath.row]), placeholderImage: nil)
                }
                else {
                    cell.gallaryImgView.image = nil
                }
            
            return cell
        }
        storyItemSize = CGSize.init(width: 40, height: 40)
       
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGStoryListCell.reuseIdentifier,for: indexPath) as? IGStoryListCell else { fatalError() }
            let story = viewModel.cellForItemAtActual(indexPath: indexPath)
            cell.story = story
            return cell
    }
    
    func addStoryButtonPressed() {
        let storiesController = StoriesController()
        storiesController.currentUserDocument = userDocument
        storiesController.addStory()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == gallaryCollectionView){
            return
        }
        if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
            let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row)
            self.present(storyPreviewScene, animated: true, completion: nil)
        }
    }
    
    @objc override func rightBarBtnClicked(sender:UIButton) {
        
        switch sender.tag {
        case 1:
            if let user = Auth.auth().currentUser {
                let vc = ChannelsViewController(currentUser: user)
                UIApplication.visibleViewController.present(UINavigationController.init(rootViewController: vc), animated: true, completion: nil)
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
//            let vc = ChannelsViewController(currentUser: user)
//            let controller = UINavigationController.init(rootViewController: vc)
//            controller.modalPresentationStyle = .overFullScreen
//            UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
            createChannelAndPushVc()
        }
    }
    func createChannelAndPushVc() {
        let user = userDocument!.data()
                    let channelName = user["fullName"] as! String
                    let recieverId = user["userId"] as! String
                    let userName = user["userName"] as! String
                    var profilePic = ""
                    if let imgsArr = (user["bioPics"] as? [String]) {
                            if(imgsArr.count > 0) {
                                profilePic = imgsArr[0]
                            }
                    }
                SVProgressHUD.show()
                self.channelReference.getDocuments(completion: { (snapshot, error) in
                    
                    var doc:QueryDocumentSnapshot?
                    for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
                        if((document.data()["userIds"] as! NSArray).contains(recieverId)) {
                            doc = document
                            break
                        }
                    }
                    SVProgressHUD.dismiss()
                    if (doc != nil) {
                        let channel = Channel.init(document: doc!)
                        let vc = ChatViewController(user: self.user, channel: channel!)
                        let controller = UINavigationController.init(rootViewController: vc)
                        controller.modalPresentationStyle = .overFullScreen
                        UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
                    }
                    else {
                        SVProgressHUD.show()
                        let channel = Channel(name: channelName, createrName: AppSettings.fullName,createrId: self.user.uid, userIds: [recieverId, self.user.uid], userName:userName, profilePicUrl:profilePic, createrProfilePicUrl:AppSettings.profilePicUrl, createUserName:AppSettings.userName)
                        self.db.collection("channels").addDocument(data: channel.representation) { error in
                            SVProgressHUD.dismiss()
                            if let e = error {
                                UIApplication.showMessageWith(e.localizedDescription)
                                print("Error saving channel: \(e.localizedDescription)")
                            }
                            else {
                                SVProgressHUD.show()
                                self.channelReference.getDocuments(completion: { (snapshot, error) in
                                    var doc:QueryDocumentSnapshot?
                                    for document in snapshot?.documents ?? [QueryDocumentSnapshot]() {
                                        if((document.data()["userIds"] as! NSArray).contains(recieverId)) {
                                            doc = document
                                            break
                                        }
                                    }
                                    SVProgressHUD.dismiss()
                                    if (doc != nil) {
                                        let channel = Channel.init(document: doc!)
                                        let vc = ChatViewController(user: self.user, channel: channel!)
                                        let controller = UINavigationController.init(rootViewController: vc)
                                        controller.modalPresentationStyle = .overFullScreen
                                        UIApplication.visibleViewController.present(controller, animated: true, completion: nil)
                                    }
                                })
                            }
                        }
                    }
                })
    }
    
    @IBAction func followBtnPressed(_ sender: UIButton) {
        if(listType == .followed) {
            unfollow(personUserId:personId)
        }
        else if(listType == .pending) {
            cancelFollowRequest(personUserId: personId)
        }
        else if(listType == .suggested) {
            followRequest(personUserId: personId, status: "")
        }
    }
    
    func cancelFollowRequest(personUserId:String) {
        SVProgressHUD.show()
        //        let myRef = db.collection("users").whereField("userId", isEqualTo: user.uid)
        //        myRef.getDocuments { (snapshot, error) in
        //  let document = currentUserDocument//snapshot?.documents[0]
        var requestSentArr = AppSettings.currentUserSnapshot?.data()["requestSent"] as? [String] ?? Array<String>()
        for i in 0..<(requestSentArr.count) {
            if(requestSentArr[i] == personUserId) {
                requestSentArr.remove(at: i)
                break
            }
        }
        AppSettings.currentUserSnapshot?.reference.updateData(["requestSent" : requestSentArr], completion: { (error) in
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
                SVProgressHUD.dismiss()
            }
            else {
                //   let otherUserRef = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                //  otherUserRef.getDocuments(completion: { (snapshot, error) in
                //  if(snapshot?.documents.count ?? 0 > 0) {
                //  let document = snapshot?.documents[0]
                var pendingArr = self.userDocument?.data()["pending"] as? [String] ?? Array<String>()
                for i in 0..<(pendingArr.count) {
                    if(pendingArr[i] == self.user.uid) {
                        pendingArr.remove(at: i)
                        break
                    }
                }
                self.userDocument?.reference.updateData(["pending":pendingArr], completion: { (error) in
                    SVProgressHUD.dismiss()
                })
                // }
                //  })
                self.reloadCurrentUserData()
                
            }
        })
        // }
    }
    
    func followRequest(personUserId:String, status:String) {
        
        SVProgressHUD.show()
        //let ref1 = db.collection("users").whereField("userId", isEqualTo: user.uid)
        //  ref1.getDocuments { (snapshot, error) in
        //      let document = snapshot?.documents[0]
        let myName = AppSettings.currentUserSnapshot?.data()["fullName"] as? String ?? ""
        var requestSentArr = AppSettings.currentUserSnapshot?.data()["requestSent"] as? [String] ?? Array<String>()
        if(!requestSentArr.contains(personUserId)) {
            requestSentArr.append(personUserId)
        }
        AppSettings.currentUserSnapshot?.reference.updateData(["requestSent":requestSentArr], completion: { (error) in
            
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                // let ref = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                //  ref.getDocuments { (snapshot, error) in
                //    let document = snapshot?.documents[0]
                var followRequestsArr = self.userDocument?.data()["pending"] as? [String] ?? Array<String>()
                if(!followRequestsArr.contains(self.user.uid)) {
                    followRequestsArr.append(self.user.uid)
                }
                let token = (self.userDocument?.data()["fcmToken"] as? String ?? "")
                PushNotificationSender().sendPushNotification(to: token, title: "Follow Request:", body: "\(myName) sent you follow request.", type: "Follow Request", id: self.user.uid)
                self.userDocument?.reference.updateData(["pending":followRequestsArr], completion: { (error) in
                    if let e = error {
                        UIApplication.showMessageWith(e.localizedDescription)
                    }
                    SVProgressHUD.dismiss()
                    self.reloadCurrentUserData()

                })
                //}
            }
        })
        // }
        
        
    }
    
    func unfollow(personUserId:String) {
        SVProgressHUD.show()
        //  let ref1 = db.collection("users").whereField("userId", isEqualTo: user.uid)
        //   ref1.getDocuments { (snapshot, error) in
        //   let document = snapshot?.documents[0]
        var followedArr = AppSettings.currentUserSnapshot?.data()["followed"] as? [String] ?? Array<String>()
        for i in 0..<(followedArr.count) {
            if(followedArr[i] == personUserId) {
                followedArr.remove(at: i)
                break
            }
        }
        AppSettings.currentUserSnapshot?.reference.updateData(["followed":followedArr], completion: { (error) in
            
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
            }
            else {
                //   let ref = self.db.collection("users").whereField("userId", isEqualTo: personUserId)
                // ref.getDocuments { (snapshot, error) in
                //     let document = snapshot?.documents[0]
                var followRequestsArr = self.userDocument?.data()["pending"] as? [String] ?? Array<String>()
                for i in 0..<(followRequestsArr.count) {
                    if(followRequestsArr[i] == self.user.uid) {
                        followRequestsArr.remove(at: i)
                        break
                    }
                }
                var followedByArr = self.userDocument?.data()["followedBy"] as? [String] ?? Array<String>()
                for i in 0..<(followedByArr.count) {
                    if(followedByArr[i] == self.user.uid) {
                        followedByArr.remove(at: i)
                        break
                    }
                }
                self.userDocument?.reference.updateData(["pending":followRequestsArr, "followedBy":followedByArr], completion: { (error) in
                    if let e = error {
                        UIApplication.showMessageWith(e.localizedDescription)
                    }
                    SVProgressHUD.dismiss()
                    self.reloadCurrentUserData()
                })
                //  }
            }
        })
        // }
    }
    
    func reloadCurrentUserData() {
        
        SVProgressHUD.show()
        let ref = db.collection("users").whereField("userId", isEqualTo: user.uid)
        ref.getDocuments { (snapshot, error) in
            if let e = error {
                SVProgressHUD.dismiss()
                UIApplication.showMessageWith(e.localizedDescription )
                return
            }
            if(snapshot?.documents.count == 0) {
            }
            else {
                for i in 0..<snapshot!.documents.count {
                    if(snapshot!.documents[i].data()["userId"] as! String == self.user.uid) {
                        AppSettings.currentUserSnapshot = snapshot!.documents[i]
                        break
                    }
                }
                self.configFollowBtn()
            }
            SVProgressHUD.dismiss()
        }
    }
}




