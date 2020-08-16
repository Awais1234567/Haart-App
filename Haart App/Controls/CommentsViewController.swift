//
//  CommentsViewController.swift
//  Haart App
//
//  Created by Stone on 25/05/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
//import MessageInputBar
import FirebaseAuth
import FirebaseFirestore
import Firebase
import MessageKit
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

class CommentssViewController: AbstractControl, UITextViewDelegate {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.estimatedRowHeight = 65
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var captionView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addBorder(toSide: .Bottom, withColor: UIColor.systemGray.cgColor, andThickness: 0.5)
        return view
    }()
    

    var commentsReference: CollectionReference!
    var post = [String:Any]()
      var postCommentsDoc:[QueryDocumentSnapshot]?
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
        view.backgroundColor = UIColor.haartRed
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cellId")
        setupViews()
        let path = ["posts", post["id"] as! String, "comments"].joined(separator: "/")

        commentsReference =  db.collection(path)//db.collection("comments_\(post["id"] ?? "")")
        commentsReference.getDocuments(completion: {(snapshot, error) in
            if let documents = snapshot?.documents {
                self.postCommentsDoc = documents
                self.tableView.reloadData()
                print(documents.count)
                for i in 0..<(documents.count) {
                    
                    print(documents[i].data()["comment"])
                }
            }
            
        })
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
    func setupViews(){
        view.addSubview(captionView)
        view.addSubview(tableView)
        
        
        NSLayoutConstraint.activate([
            captionView.topAnchor.constraint(equalTo: view.topAnchor),
            captionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captionView.heightAnchor.constraint(equalToConstant: 60 * appConstant.heightRatio),
            
            tableView.topAnchor.constraint(equalTo: captionView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          
            
        ])
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

extension CommentssViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Use to send the message
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.text = String()
        //messageInputBar.invalidatePlugins()
        
        commentsReference.addDocument(data: ["userId":user.uid, "comment":text, "userPic":"", "timeStamp":Date()]) { (error) in
                print(error?.localizedDescription ?? "no error")
            }
           self.tableView.reloadData()
     }
    
//    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
//        // Use to send a typing indicator
//    }
//
//    func messageInputBar(_ inputBar: MessageInputBar, didChangeIntrinsicContentTo size: CGSize) {
//        // Use to change any other subview insets
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("stard")
    }
}
extension CommentssViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = postCommentsDoc{
            return comments.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! CommentCell
        if let comments = postCommentsDoc{
            cell.setData(userDocument: comments[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

