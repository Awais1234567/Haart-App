//
//  FeedControl.swift
//  Haart App
//
//  Created by Stone on 31/01/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import SDWebImage
import YPImagePicker
import Firebase

class FeedControl: AbstractControl,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,IGAddStoryCellDelegate {
    
    private var viewModel: IGHomeViewModel = IGHomeViewModel()
    var feedsArr = [[String:Any]]()
    var image: UIImage!
    @IBOutlet weak var storyContainer: UIView!
    @IBOutlet weak var tblView: UITableView!
    var _storiesView:IGHomeView!
    
    override func loadView() {
        super.loadView()
        _storiesView = IGHomeView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 104))
        storyContainer.addSubview(_storiesView)
        _storiesView.collectionView.setCollectionViewLayout(_storiesView.layout, animated: false)
        
        _storiesView.collectionView.delegate = self
        _storiesView.collectionView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor.haartRed
        self.navigationController?.view.backgroundColor = UIColor.red
        tblView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "FeedCell")
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: nil)
        if(feedsArr.count > 1) {
            feedsArr.removeFirst()
        }
        print(feedsArr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  getData()
    }
    
    func getData() {
        if(self.userDocument == nil) {
            SVProgressHUD.show()
        }
        var storiesArr = [[String:Any]]()
        let ref = db.collection("users")//.whereField("userId", isEqualTo: self.user.uid)
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
                        break
                    }
                }
                
                for i in 0..<snapshot!.documents.count {//fetch stories of followed persons
                    if((self.userDocument?.data()["blocked"] as? Array<String> ?? [String]()).contains(snapshot!.documents[i].data()["userId"] as! String)) {
                        //do not show
                    }
                    else if((snapshot!.documents[i].data()["blocked"] as? Array<String> ?? [String]()).contains(self.user.uid)) {
                        //do not show
                    }
                    else if ((self.userDocument!.data()["followed"] as? Array<String> ?? Array<String>()).contains(snapshot!.documents[i].data()["userId"] as! String)){
                        if let userStories = snapshot?.documents[i].data()["stories"] as? [String:Any] {
                            storiesArr.append(userStories)
                        }
                    }
                }
                
                print(storiesArr)
                let storiesController = StoriesController()
                storiesController.currentUserDocument = self.userDocument
                self.viewModel.stories = storiesController.returnAndSetValidStories(storiesArr: storiesArr)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        cell.profilePicImgView.image = image
        cell.setData(data: feedsArr[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 415
    }
    
    //MARK: - Private functions
    @objc private func clearImageCache() {
        IGCache.shared.removeAllObjects()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        storyItemSize = CGSize.init(width: 40, height: 40)
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGAddStoryCell.reuseIdentifier, for: indexPath) as? IGAddStoryCell else { fatalError() }
            cell.userDetails = ("Your Story","")
            cell.delegate = self
            //            if(viewModel.getStories()?.count ?? 0 > 0) {
            //                cell.story = viewModel.cellForItemAtActual(indexPath: indexPath)
            //            }
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
        
        if indexPath.row == 0 {
            addStoryButtonPressed()
        } else {
            DispatchQueue.main.async {
                if let stories = self.viewModel.getStories(), let stories_copy = try? stories.copy() {
                    let storyPreviewScene = IGStoryPreviewController.init(stories: stories_copy, handPickedStoryIndex:  indexPath.row - 1)
                    self.present(storyPreviewScene, animated: true, completion: nil)
                }
            }
        }
    }
    
}
