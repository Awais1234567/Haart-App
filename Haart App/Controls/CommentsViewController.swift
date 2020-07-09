//
//  CommentsViewController.swift
//  Haart App
//
//  Created by Stone on 25/05/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import MessageInputBar
import FirebaseAuth
import FirebaseFirestore
import Firebase
//enum MessageInputBarStyle: String {
//    case imessage = "iMessage"
//    case slack = "Slack"
//    case githawk = "GitHawk"
//    case facebook = "Facebook"
//    case `default` = "Default"
//
//    func generate() -> MessageInputBar {
//        return MessageInputBar()
////        switch self {
////        case .imessage: return iMessageInputBar()
////        case .slack: return SlackInputBar()
////        case .githawk: return GitHawkInputBar()
////        case .facebook: return FacebookInputBar()
////        case .default: return MessageInputBar()
////        }
//    }
//}

class CommentsViewController: AbstractControl {
    
    var commentsReference: CollectionReference!
    var post = [String:Any]()
      var postCommentsDoc:QueryDocumentSnapshot?
    override var inputAccessoryView: UIView? {
        return messageInputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - MessageInputBar
    
    private var messageInputBar: MessageInputBar = MessageInputBar()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = ["posts", post["id"] as! String, "comments"].joined(separator: "/")

        commentsReference =  db.collection(path)//db.collection("comments_\(post["id"] ?? "")")
        print(post)
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: nil)
        messageInputBar.delegate = self
       
//        commentsReference.getDocuments { (snapshot, error) in
//            if(snapshot?.documents.count ?? 0 > 0) {
//                self.postCommentsDoc = snapshot?.documents[0]
//            }
//            else {
//
//            }
//        }
    }
    
    override func leftBarBtnClicked(sender: UIButton) {
        close()
    }
    
    func close() {
        self.view.endEditing(true)
        if let nv = self.navigationController {
            nv.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension CommentsViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Use to send the message
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
            commentsReference.addDocument(data: ["userId":user.uid, "comment":text, "userPic":"", "timeStamp":Date()]) { (error) in
                print(error?.localizedDescription ?? "no error")
            }
     }
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        // Use to send a typing indicator
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didChangeIntrinsicContentTo size: CGSize) {
        // Use to change any other subview insets
    }
    
}
