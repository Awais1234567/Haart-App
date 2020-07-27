/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Photos
import Firebase
import MessageKit
import FirebaseFirestore
import SVProgressHUD
import FirebaseAuth
import Quickblox
import QuickbloxWebRTC
import PushKit

final class ChatViewController: MessagesViewController {
    
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    item.isEnabled = !self.isSendingPhoto
                }
            }
        }
    }
    
    private let db = Firestore.firestore()
    
    private var reference: CollectionReference?
    // private var channelReference: Query?
    private var updateReference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    private var messageUpdateListener: ListenerRegistration?
    private let user: User
    private let channel: Channel
    var timeLbl = UILabel()
    
    //Quick Blox
    private weak var session: QBRTCSession?
    private var callUUID: UUID?
    private var sessionID: String?
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    private var isUpdatedPayload = true
    var messageReceiverId = ""
    private var answerTimer: Timer?
    lazy private var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    
    deinit {
        messageListener?.remove()
        messageUpdateListener?.remove()
    }
    
    init(user: User, channel: Channel) {
        self.user = user
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        if(channel.createrId == Auth.auth().currentUser?.uid) {
            title = channel.name
        }
        else {
            title = channel.createrName
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#EC2B00")
        let rect = CGRect(x: 0, y: 0, width: 40, height: 35)
        let leftBtn = UIButton.init(frame: rect)
        leftBtn.setImage(UIImage.init(named: "Back")!, for: .normal)
        leftBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        let rightBtn = UIButton.init(frame: rect)
        rightBtn.setImage(UIImage(named: "Call")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightBtn.tintColor = UIColor.white
        rightBtn.imageView?.contentMode = .scaleAspectFit
        rightBtn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
        rightBtn.addTarget(self, action: #selector(didPressAudioCall(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        
        guard let id = channel.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        let path = ["channels", id, "thread"].joined(separator: "/")
        reference = db.collection(path)
        //  channelReference = db.collection("channels").whereField("id", isEqualTo: id)
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
            //      self.view.addSubview(self.timeLbl)
            //      self.timeLbl.backgroundColor = UIColor.init(hexString: "C4E2FF")
            //      self.timeLbl.font = UIFont.systemFont(ofSize: 12)
        }
        
        messageUpdateListener = updateReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let cameraItem = InputBarButtonItem(type: .system) // 1
        cameraItem.tintColor = .primary
        cameraItem.image = UIImage.init(named: "ic_camera")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed), // 2
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false) // 3
        
        messagesCollectionView.topConstraint?.isActive = false
        messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        QBRTCClient.instance().add(self)
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        if(timeLbl.superview != nil) {
        //
        //            NSLayoutConstraint.activate([
        //                    timeLbl.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10)
        //                    ])
        //            self.view.addConstraintSameCenterX(self.view, view2: timeLbl)
        //            _ = self.timeLbl.addConstraintForHeight(20)
        //            _ = self.timeLbl.addConstraintForWidth(100)
        //        }
    }
    // MARK: - Actions
    
    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let ac = UIAlertController(title: nil, message: "Select Source", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Camera", style: .destructive, handler: { _ in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }))
        
        ac.addAction(UIAlertAction(title: "Photo Library", style: .destructive, handler: { _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    private func save(_ message: Message) {
        
        //    channelReference?.getDocuments(completion: { (snapshot, error) in
        //        if let documents = snapshot?.documents {
        //            if(documents.count == 1) {
        //                let doc = documents[0]
        //                doc.reference.updateData(["timeStamp":Date()], completion: nil)
        //            }
        //        }
        //    })
        messageInputBar.inputTextView.resignFirstResponder()
        
        reference?.addDocument(data: message.representation) { error in
            if let e = error {
                UIApplication.showMessageWith(e.localizedDescription)
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            
            
            for id in self.channel.userIds {
                if(id != self.user.uid) {
                    self.messageReceiverId = id
                }
            }
            let ref = self.db.collection("users").whereField("userId", isEqualTo: self.messageReceiverId)
            ref.getDocuments(completion: { (snapShot, e) in
                if(snapShot?.documents.count ?? 0 > 0){
                    let deviceToken = snapShot?.documents[0].data()["fcmToken"] as? String ?? ""
                    
                    if let url = message.downloadURL {
                        //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3){
                        PushNotificationSender().sendPushNotification(to: deviceToken, title: message.sender.displayName, body: "Photo", imgUrl: url.absoluteString,  type:"Message", id:self.user.uid)
                        // }
                    }
                    else {
                        PushNotificationSender().sendPushNotification(to: deviceToken, title: message.sender.displayName, body: message.content,  type:"Message", id:self.user.uid)
                    }
                }
            })
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    func updateMessageInOnlineDB(_ message: Message) { // update when message is received
        let path1 = ["channels", channel.id!, "thread"].joined(separator: "/")
        let updateReference = db.collection(path1).document(message.id!)
        updateReference.getDocument { (document, err) in
            if let err = err {
                UIApplication.showMessageWith(err.localizedDescription)
                print(err.localizedDescription)
            }
            else {
                document?.reference.updateData([
                    "isRead": true
                ])
            }
        }
    }
    
    private func updateMessage(_ message: Message) { //called after message is update in online db
        var i = 0
        for msg in messages {
            if(msg.id == message.id) {
                messages[i] = message
                break
            }
            i = i + 1
        }
        messagesCollectionView.reloadData()
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        if(message.sender.id != user.uid){
            updateMessageInOnlineDB(message)
        }
        
        messages.sort()
        
        let isLatestMessage = messages.index(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard var message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                downloadImage(at: url) { [weak self] image in
                    guard let `self` = self else {
                        return
                    }
                    guard let image = image else {
                        return
                    }
                    
                    message.image = image
                    self.insertNewMessage(message)
                }
            } else {
                insertNewMessage(message)
            }
            break
        case .modified:
            updateMessage(message)
            break
        default:
            break
        }
    }
    
    private func uploadImage(_ image: UIImage, to channel: Channel, completion: @escaping (URL?) -> Void) {
        guard let channelID = channel.id else {
            completion(nil)
            return
        }
        
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
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
    // MARK: - GET DOWNLOAD URL
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        storage.child(path).downloadURL(completion: completion)
    }
    
    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        SVProgressHUD.show()
        uploadImage(image, to: channel) { [weak self] url in
            guard let `self` = self else {
                return
            }
            self.isSendingPhoto = false
            
            guard let url = url else {
                return
            }
            
            var message = Message(user: self.user, image: image)
            message.downloadURL = url
            
            self.save(message)
            SVProgressHUD.dismiss()
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom({ (view) in
            if(self.isFromCurrentSender(message: message)) {
                view.roundForMessageSender()
            }
            else {
                view.roundForMessageOtherUser()
            }
        })
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor.white
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        
        // get previous message
        let previousIndexPath = IndexPath(row: 0, section: indexPath.section - 1)
        let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        
        if message.sentDate.isInSameDay(as: previousMessage.sentDate){
            return false
        }
        
        return true
        // return false
    }
    
    func messageHeaderView(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageHeaderView {
        let header = messagesCollectionView.dequeueReusableHeaderView(MessageDateHeaderView.self, for: indexPath)
        var calender = Calendar.current
        calender.locale = Locale.current
        calender.timeZone = TimeZone.current
        if(calender.isDateInToday(message.sentDate)) {
            header.dateLabel.text = "Today"
        }
        else if(calender.isDateInYesterday(message.sentDate)) {
            header.dateLabel.text = "Yesterday"
        }
        else if(calender.isDateInWeekend(message.sentDate)) {
            header.dateLabel.text = message.sentDate.string("EEEE")
        }
        else {
            header.dateLabel.text = message.sentDate.string("dd/MMM/YYYY")
        }
        return header
    }
    
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
}


// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: user.uid, displayName: AppSettings.displayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // let name = message.sender.displayName
        let message = messages[indexPath.section]
        
        var string = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "hh:mm a"
        let time = dateFormatter.string(from: message.sentDate)
        
        if(currentSender().id == message.sender.id) {
            string = message.read ? "\(time) Seen" : "\(time) Delivered"
        }
        else {
            string = "\(time)"
        }
        return NSAttributedString(
            string: string,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if(isFromCurrentSender(message: message)) {
            return LabelAlignment.messageTrailing(UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 3))
        }
        return LabelAlignment.messageLeading(UIEdgeInsets.init(top: 0, left: 3, bottom: 0, right: 0))
    }
    
    //  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //    let name = message.sender.displayName
    //    return NSAttributedString(
    //      string: name,
    //      attributes: [
    //        .font: UIFont.preferredFont(forTextStyle: .caption1),
    //        .foregroundColor: UIColor(white: 0.3, alpha: 1)
    //      ]
    //    )
    //  }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Message(user: user, content: text)
        
        save(message)
        inputBar.inputTextView.text = ""
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if #available(iOS 11.0, *) {
            if let asset = info[.phAsset] as? PHAsset { // 1
                let size = CGSize(width: 500, height: 500)
                PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                    guard let image = result else {
                        return
                    }
                    
                    self.sendPhoto(image)
                }
            } else if let image = info[.originalImage] as? UIImage { // 2
                sendPhoto(image)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func backBtnPressed() {
        if(self.navigationController?.viewControllers.count == 1) {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func didPressAudioCall(sender: UIButton){
        if let user = Auth.auth().currentUser{
            login(fullName: user.uid, login: user.uid, password: user.uid)
        }
    }
}


extension ChatViewController{
    
    private func login(fullName: String, login: String, password: String) {
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
                            print(response)
                            print(user)

                            user.password = password
                            user.updatedAt = Date()
                            QuickBloxProfile.synchronize(user)
                            
                            if user.fullName != fullName {
                                //self?.updateFullName(fullName: fullName, login: login)
                            } else {
                                self?.connectToChat(user: user)
                            }
            }, errorBlock: { [weak self] response in
                //self?.handleError(response.error?.error, domain: ErrorDomain.logIn)
                if response.status == QBResponseStatusCode.unAuthorized {
                    // Clean profile
                    QuickBloxProfile.clearProfile()
                    //self?.defaultConfiguration()
                }
        })
    }
    
    private func connectToChat(user: QBUUser) {
        //infoText = LoginStatusConstant.intoChat
        if !QBChat.instance.isConnected{
            if let firebaseUser = Auth.auth().currentUser{
                QBChat.instance.connect(withUserID: user.id,
                                        password: firebaseUser.uid,
                                        completion: { [weak self] error in
                                            if let error = error {
                                                if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                    // Clean profile
                                                    QuickBloxProfile.clearProfile()
                                                } else {
                                                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                                                }
                                            } else {
                                                // Reachability
                                                if QuickbloxReachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
                                                    self!.loadUsers()
                                                }
                                            }
                })
            }
        }else{
            loadUsers()
        }
        
        
    }
    
    func loadUsers() {
        let firstPage = QBGeneralResponsePage(currentPage: 1, perPage: 100)
        QBRequest.users(withExtendedRequest: ["order": "desc date updated_at"],
                        page: firstPage,
                        successBlock: { [weak self] (response, page, users) in
                            self?.dataSource.update(users: users)
                            if let toCallUsers = self?.selectedUser(users: users){
                                self?.call(with: .audio, toUser: toCallUsers)
                            }else{
                                SVProgressHUD.showError(withStatus: "User is not yet registered to receive calls")
                            }
                            
                            
            }, errorBlock: { response in
                //debugPrint("[UsersViewController] loadUsers error: \(self.errorMessage(response: response) ?? "")")
        })
    }
    private func call(with conferenceType: QBRTCConferenceType, toUser: [QBUUser]) {
        //session = nil
        if session != nil {
            return
        }

        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { granted in
                if granted {
                    CallKitManager.instance.usersDatasource = self.dataSource
                    self.dataSource.selectUser(at: IndexPath(row: 0, section: 0))
                    let opponentsIDs: [NSNumber] = self.dataSource.ids(forUsers: toUser)
                    let opponentsNames: [String] = self.dataSource.selectedUsers.compactMap({ $0.fullName ?? $0.login })

                    //Create new session
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: conferenceType)
                    print(session)
                    print(session.id)
                    if session.id.isEmpty == false {
                        self.session = session
                        self.sessionID = session.id
                        guard let uuid = UUID(uuidString: session.id) else {
                            return
                        }
                        self.callUUID = uuid
                        let profile = QuickBloxProfile()
                        guard profile.isFull == true else {
                            return
                        }

                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)

                            let callViewController = CallViewController()
                            callViewController.session = self.session
                            callViewController.usersDataSource = self.dataSource
                            callViewController.callUUID = uuid
                            callViewController.sessionConferenceType = conferenceType
                            let nav = UINavigationController(rootViewController: callViewController)
                            nav.modalTransitionStyle = .crossDissolve
                            nav.modalPresentationStyle = .fullScreen
                            UIApplication.visibleNavigationController.pushViewController(callViewController, animated: true)
                            //self.present(nav, animated: false)
                            //self.audioCallButton.isEnabled = false
                            //self.videoCallButton.isEnabled = false
                            //self.navViewController = nav

                        let opponentsNamesString = opponentsNames.joined(separator: ",")
                        let allUsersNamesString = "\(profile.fullName)," + opponentsNamesString
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        let usersIDsString = arrayUserIDs.joined(separator: ",")
                        let allUsersIDsString = "\(profile.ID)," + usersIDsString
                        let opponentName = profile.fullName
                        let conferenceTypeString = conferenceType == .video ? "1" : "2"
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let timeStamp = formatter.string(from: Date())
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1",
                            "VOIPCall": "1",
                            "sessionID": session.id,
                            "opponentsIDs": allUsersIDsString,
                            "contactIdentifier": allUsersNamesString,
                            "conferenceType" : conferenceTypeString,
                            "timestamp" : timeStamp
                        ]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        event.usersIDs = usersIDsString
                        event.type = QBMEventType.oneShot
                        event.message = message
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[UsersViewController] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[UsersViewController] Send voip push - Error")
                        })
                    } else {
                        SVProgressHUD.showError(withStatus: "You should login to use VideoChat API. Session hasn’t been created. Please try to relogin.")
                    }
                }
            }
        }
    }
    func selectedUser(users: [QBUUser])->[QBUUser]!{
        var user = [QBUUser]()
        for i in channel.userIds{
            if i != Auth.auth().currentUser?.uid{
                for j in users{
                    if i == j.login!{
                        user.append(j)
                    }
                }
            }
        }
        if user.count > 0 {
            return user
        }else{
           return nil
        }
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


extension ChatViewController: PKPushRegistryDelegate {
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
            debugPrint("[UsersViewController] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            UIApplication.shared.unregisterForRemoteNotifications()
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
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
                            self?.dataSource.update(users: users)
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
extension ChatViewController: QBRTCClientDelegate {
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
            if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: UsersSegueConstant.call) as? CallViewController {
                if let qbSession = session {
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
}
// MARK: - SettingsViewControllerDelegate
extension ChatViewController: SettingsViewControllerDelegate {
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

