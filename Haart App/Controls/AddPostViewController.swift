//
//  AddPostViewController.swift
//  Haart App
//
//  Created by Stone on 18/05/20.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import UIKit

protocol AddPostViewControllerDelegate: class {
    func didSelectMedia(image: UIImage?, video:Any?, caption:String?)
}

class AddPostViewController: AbstractControl {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var txtView: HaartTextView!
    weak var delegate: AddPostViewControllerDelegate?

    var selectedImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = selectedImage
        txtView.placeholderText = "Write a caption..."
        self.title = "New Post"
        self.setNavBarButtons(letfImages: [UIImage.init(named: "Back")!], rightImage: nil)
        submitBtn.backgroundColor = .red
        submitBtn.layer.cornerRadius = 6
        submitBtn.layer.masksToBounds = true
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        delegate?.didSelectMedia(image: selectedImage, video: nil, caption: txtView.text ?? "")
        close()
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
}
