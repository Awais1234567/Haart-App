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
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD
class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.estimatedRowHeight = 65
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.backgroundColor = UIColor.paleGrey()
        //tableView.sectionIndexColor = UIColor.cerulean()
        //tableView.sectionIndexBackgroundColor = UIColor.ublWhite1()
        //tableView.refreshControl = self.refereshControl
        return tableView
    }()
    private let toolbarLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    private let channelCellIdentifier = "channelCell"
    private var currentChannelAlertController: UIAlertController?
    var recieverId = String()
    private let db = Firestore.firestore()
    
    private var channelReference: Query {
        return db.collection("channels").whereField("userIds", arrayContains: currentUser.uid)
    }
    
    private var channels = [Channel]()
    private var channelListener: ListenerRegistration?
    
    private let currentUser: User
    
    
//    init(currentUser: User) {
//        self.currentUser = currentUser
//        title = "Messages"
//        print(currentUser.uid)
////        let control = AbstractControl()
////        let ref = control.db.collection("users").whereField("userId", isEqualTo: otherUserId)
////        ref.getDocuments(completion: {(snapshot, error)in
////            print(snapshot?.documents[0].data()["fullName"] as? String)
////
////        })
//
//    }
   
    init(currentUser: User) {
        self.currentUser = currentUser
        print(currentUser.uid)
        super.init(nibName: nil, bundle: nil)
        self.title = "Messages"
        
        print(channels)
//        let controller = AbstractControl()
//        let ref = controller.db.collection("users").whereField("userId", isEqualTo: currentUser.uid)
//        ref.getDocuments { (snapshot, error) in
//
//
//            if(snapshot?.documents.count == 0) {
//
//            }
//            print(snapshot?.documents[0])
//        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexString: "#EC2B00")
        setupViews()
        
        let rect = CGRect(x: 0, y: 0, width: 40, height: 35)
        let btn = UIButton.init(frame: rect)
        btn.setImage(UIImage.init(named: "Back")!, for: .normal)
        btn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        
        //tableView.clearsSelectionOnViewWillAppear = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
        tableView.backgroundColor = UIColor.white
        tableView.register(ChannelssCell.self, forCellReuseIdentifier: "ChannelsCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        channelListener = channelReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                UIApplication.showMessageWith(error?.localizedDescription ?? "No error")
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        channelListener?.remove()
    }
    
    @objc func backBtnPressed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func createChannel() {
        //    guard let ac = currentChannelAlertController else {
        //      return
        //    }
        //
        //    guard let channelName = ac.textFields?.first?.text else {
        //      return
        //    }
        //    SVProgressHUD.show()
        //    let channel = Channel(name: channelName, userIds: [recieverId, currentUser.uid])
        //    db.collection("channels").addDocument(data: channel.representation) { error in
        //        SVProgressHUD.dismiss()
        //      if let e = error {
        //        UIApplication.showMessageWith(e.localizedDescription)
        //        print("Error saving channel: \(e.localizedDescription)")
        //      }
        //    }
    }
    
    private func addChannelToTable(_ channel: Channel) {
        guard !channels.contains(channel) else {
            return
        }
        
        channels.append(channel)
        channels.sort()
        
        guard let index = channels.index(of: channel) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.index(of: channel) else {
            return
        }
        
        channels[index] = channel
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.index(of: channel) else {
            return
        }
        
        channels.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addChannelToTable(channel)
            
        case .modified:
            updateChannelInTable(channel)
            
        case .removed:
            removeChannelFromTable(channel)
        }
    }
    
}

// MARK: - TableViewDelegate

extension ChannelsViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelsCell", for: indexPath) as! ChannelssCell
        cell.setData(channel:channels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        let vc = ChatViewController(user: currentUser, channel: channel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
