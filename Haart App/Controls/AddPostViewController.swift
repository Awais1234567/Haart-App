//
//  AddPostViewController.swift
//  Haart App
//
//  Created by Stone on 18/05/20.
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

protocol AddPostViewControllerDelegate: class {
    func didSelectMedia(image: UIImage?, video:YPMediaVideo?, caption:String?)
}

class AddPostViewController: AbstractControl {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var txtView: HaartTextView!
    weak var delegate: AddPostViewControllerDelegate?
    let defaults = UserDefaults.standard
    private let storage = Storage.storage().reference()
    var selectedImage = UIImage()
    var selectedVideoThumb = UIImage()
    var selectedVideoUrl = URL(string: "")
      var galleryItemsArr:[[String:Any]] = [["void":""]]
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        if(selectedVideoUrl == nil){
            print("its a pic")
               imgView.image = selectedImage
        }else{
            imgView.image = selectedVideoThumb
            print("its a video")
     
        }
        txtView.placeholderText = "Write a caption..."
        self.title = "New Post"
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: nil)
        submitBtn.backgroundColor = .red
        submitBtn.layer.cornerRadius = 6
        submitBtn.layer.masksToBounds = true
    }
    
    
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
                        
                        
       
                        
                     //   if(self.shouldFetchImagesArr == true) { //do not update agaib and gain because already updated
                 
                        self.galleryItemsArr = self.userDocument?.data()["galleryPics"] as? [[String:Any]] ?? [["void":"","time":1]]
                      
                        break
                    }
                }

                
            

            }
        }
    }
    
    func didSelectMedia(image: UIImage?, video: YPMediaVideo?, caption: String?) {
      if(image != nil){
               print("add function called")
               SVProgressHUD.show()
               self.uploadImage(image!, "galleryImages", completion: { (url) in
                   SVProgressHUD.dismiss()
                   self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"image","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])
                SVProgressHUD.show()
                self.userDocument!.reference.updateData(["galleryPics":self.galleryItemsArr, "fcmToken":AppSettings.deviceToken], completion: { (error) in
                    SVProgressHUD.dismiss()
                    if let e = error {
                        UIApplication.showMessageWith(e.localizedDescription)
                    }
                })
                   let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileViewController")
                vc.modalPresentationStyle = .fullScreen
                            UIApplication.visibleViewController.navigationController?.pushViewController(vc, animated: true)
                
               })
    }
           
           if(video != nil){
            SVProgressHUD.show()
           print("upload Video Called")
               self.uploadVideo(video!, "galleryImages", completion: {(url) in
                      SVProgressHUD.dismiss()
               self.galleryItemsArr.append(["id":"post" + self.user.uid + ("".randomStringWithLength(len: 8) as String),"type":"video","url":url?.absoluteString ?? "", "caption":caption ?? "", "fullName": self.userDocument!["fullName"] as! String, "timeStamp":Date(), "comments":[]])


               })

           }
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        print("hit")
       
        if(selectedVideoUrl == nil){
                 print("its a pic pic")
            didSelectMedia(image: selectedImage, video: nil, caption: txtView.text ?? "")
 


        }else{
            didSelectMedia(image: nil, video: YPMediaVideo.init(thumbnail: selectedVideoThumb, videoURL: selectedVideoUrl!), caption: txtView.text ?? "")
           

             }
    }
    
    
    override func leftBarBtnClicked(sender: UIButton) {
        close()
        
    }
    
    func close() {
        if let nv = self.navigationController {
            if(nv.viewControllers.count == 1) {
                
                nv.dismiss(animated: false, completion: nil)
            }
            else {
                nv.popViewController(animated: false)
            }
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
           storage.child(path).downloadURL(completion: completion)
       }
}


