//
//  IGAddStoryCell.swift
//  InstagramStories
//
//  Created by Ranjith Kumar on 9/6/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import UIKit
import SDWebImage
protocol IGAddStoryCellDelegate: class {
    func addStoryButtonPressed()
}
final class IGAddStoryCell: UICollectionViewCell {
    
    weak var delegate: IGAddStoryCellDelegate?
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - iVars
    private let addStoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.alpha = 0.5
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    //MARK: - Public iVars
    public var story: IGStory? {
        didSet {
            //self.profileNameLabel.text = story?.user.name
            if let picture = story?.user.picture {
                self.profileImageView.imageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
                self.profileImageView.imageView.sd_setImage(with: URL(string:picture), placeholderImage: nil)
               // self.profileImageView.imageView.setImage(url: picture)
            }
        }
    }
    
    public var userDetails: (String,String)? {
        didSet {
            if let details = userDetails {
                addStoryLabel.text = details.0
                profileImageView.imageView.image = UIImage.init(named: "ui")
                //profileImageView.imageView.setImage(url: details.1)
            }
        }
    }
    
    private let profileImageView: IGRoundedView = {
        let roundedView = IGRoundedView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.enableBorder(enabled: false)
        return roundedView
    }()
    
    lazy var addButton: UIButton = {
        let iv = UIButton()
        iv.setImage(UIImage(named: "ic_Add"), for: .normal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20/2
        iv.addTarget(self, action: #selector(addBtnPressed), for: .touchUpInside)
        iv.layer.borderWidth = 2.0
        iv.layer.borderColor = UIColor.white.cgColor
        iv.clipsToBounds = true
        return iv
    }()
    
    @objc func addBtnPressed() {
        delegate?.addStoryButtonPressed()
    }
    //MARK: - Private functions
    private func loadUIElements() {
        addSubview(addStoryLabel)
        addSubview(profileImageView)
       // addSubview(addButton)
    }
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: storyItemSize.width),
            profileImageView.heightAnchor.constraint(equalToConstant: storyItemSize.height),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 13),
            profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        
        NSLayoutConstraint.activate([
            addStoryLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            addStoryLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            addStoryLabel.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 2),
            addStoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            addStoryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)])
        if(storyItemSize.height < 50) {
            _ = addStoryLabel.addConstraintForHeight(0)
        }
       
       /* NSLayoutConstraint.activate([
            addButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -17),
            addButton.widthAnchor.constraint(equalToConstant: 20),
            addButton.heightAnchor.constraint(equalToConstant: 20),
            addButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5)])*/
        
        layoutIfNeeded()
    }
}
