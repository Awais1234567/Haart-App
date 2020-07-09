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
    let rect = CGRect(x: 0, y: 0, width: 40, height: 35)
    let btn = UIButton.init(frame: rect)
    btn.setImage(UIImage.init(named: "Back")!, for: .normal)
    btn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    
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
        
        var messageReceiverId = ""
        for id in self.channel.userIds {
            if(id != self.user.uid) {
                messageReceiverId = id
            }
        }
        let ref = self.db.collection("users").whereField("userId", isEqualTo: messageReceiverId)
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
            string = message.read ? "\(time) Read" : "\(time) Not Read"
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
}
