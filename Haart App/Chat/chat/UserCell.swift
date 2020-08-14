//
//  UserCell.swift
//  Haart App
//
//  Created by Awais Khalid on 24/07/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC
import UIKit
//class UserCell: UICollectionViewCell {
//    //MARK: - IBOutlets
//    @IBOutlet private weak var nameView: UIView!
//    @IBOutlet private weak var nameLabel: UILabel!
//    @IBOutlet private weak var containerView: UIView!
//    @IBOutlet private weak var bitrateLabel: UILabel!
//    @IBOutlet weak var muteButton: UIButton!
//    @IBOutlet weak var statusLabel: UILabel!
//
//    //MARK: - Properties
//    var videoView: UIView? {
//        didSet {
//            guard let view = videoView else {
//                return
//            }
//
//            containerView.insertSubview(view, at: 0)
//
//            view.translatesAutoresizingMaskIntoConstraints = false
//            view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//            view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//            view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
//        }
//    }
//
//    /**
//     *  Mute user block action.
//     */
//    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
//
//    var connectionState: QBRTCConnectionState = .connecting {
//        didSet {
//            switch connectionState {
//            case .new: statusLabel.text = "New"
//            case .pending: statusLabel.text = "Pending"
//            case .connected: statusLabel.text = "Connected"
//            case .closed: statusLabel.text = "Closed"
//            case .failed: statusLabel.text = "Failed"
//            case .hangUp: statusLabel.text = "Hung Up"
//            case .rejected: statusLabel.text = "Rejected"
//            case .noAnswer: statusLabel.text = "No Answer"
//            case .disconnectTimeout: statusLabel.text = "Time out"
//            case .disconnected: statusLabel.text = "Disconnected"
//            case .unknown: statusLabel.text = ""
//            default: statusLabel.text = ""
//            }
//            muteButton.isHidden = !(connectionState == .connected)
//        }
//    }
//
//    var name = "" {
//        didSet {
//            nameLabel.text = name
//            nameView.isHidden = name.isEmpty
//            nameView.backgroundColor = PlaceholderGenerator.color(index: name.count)
//            muteButton.isHidden = name.isEmpty
//        }
//    }
//
//    var bitrate: Double = 0.0 {
//        didSet {
//            if bitrate == 0.0 {
//                bitrateLabel.text = ""
//            } else if bitrate > 0.0 {
//                bitrateLabel.text = String(format: "%.0f kbits/sec", bitrate * 1e-3)
//            }
//        }
//    }
//
//    let unmutedImage = UIImage(named: "ic-qm-videocall-dynamic-off")!
//    let mutedImage = UIImage(named: "ic-qm-videocall-dynamic-on")!
//
//    //MARK: - Life Cycle
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        backgroundColor = UIColor.clear
//        bitrateLabel.backgroundColor = UIColor(red: 0.9441, green: 0.9441, blue: 0.9441, alpha: 0.350031672297297)
//        muteButton.setImage(unmutedImage, for: .normal)
//        muteButton.setImage(mutedImage, for: .selected)
//        muteButton.isHidden = true
//        muteButton.isSelected = false
//    }
//
//    //MARK: - Actions
//    @IBAction func didPressMuteButton(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        didPressMuteButton?(sender.isSelected)
//    }
//}

class UserCell: UICollectionViewCell{
    let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "img2")
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let layerOverBackgroundView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        return view
    }()
    let userImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "img2")
        view.layer.borderWidth = 5
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 75
        return view
    }()
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "nameLabel"
        label.textAlignment = .center
        label.font = label.font.withSize(32)
        label.textColor = UIColor.white
        return label
    }()
    var muteButton: UIButton = {
      let button = UIButton()
        button.setTitle("Mute", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didPressMuteButton(_:)), for: .touchUpInside)
        return button
    }()
    var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "statusLabel"
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    var videoView: UIView? {
        didSet {
            guard let view = videoView else {
                return
            }
            
            layerOverBackgroundView.insertSubview(view, at: 0)
            view.contentMode = .scaleAspectFit
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leadingAnchor.constraint(equalTo: layerOverBackgroundView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: layerOverBackgroundView.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: layerOverBackgroundView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: layerOverBackgroundView.bottomAnchor).isActive = true
        }
    }
    
    /**
     *  Mute user block action.
     */
    var didPressMuteButton: ((_ isMuted: Bool) -> Void)?
    
    var connectionState: QBRTCConnectionState = .connecting {
        didSet {
            switch connectionState {
            case .new: statusLabel.text = "New"
            case .pending: statusLabel.text = "Pending"
            case .connected: statusLabel.text = "Connected"
            case .closed: statusLabel.text = "Closed"
            case .failed: statusLabel.text = "Failed"
            case .hangUp: statusLabel.text = "Hung Up"
            case .rejected: statusLabel.text = "Rejected"
            case .noAnswer: statusLabel.text = "No Answer"
            case .disconnectTimeout: statusLabel.text = "Time out"
            case .disconnected: statusLabel.text = "Disconnected"
            case .unknown: statusLabel.text = "Calling"
            default: statusLabel.text = ""
            }
            muteButton.isHidden = !(connectionState == .connected)
        }
    }
    
    var name = "" {
        didSet {
            nameLabel.text = name
            //nameView.isHidden = name.isEmpty
            //nameLabel.backgroundColor = PlaceholderGenerator.color(index: name.count)
            muteButton.isHidden = name.isEmpty
        }
    }
    
    let unmutedImage = UIImage(named: "ic-qm-videocall-dynamic-off")!
    let mutedImage = UIImage(named: "ic-qm-videocall-dynamic-on")!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = UIColor.clear
        muteButton.setImage(unmutedImage, for: .normal)
        muteButton.setImage(mutedImage, for: .selected)
        muteButton.isHidden = false
        muteButton.isSelected = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews(){
        addSubview(backgroundImageView)
        addSubview(layerOverBackgroundView)
        addSubview(userImageView)
        addSubview(statusLabel)
        addSubview(nameLabel)
        addSubview(muteButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            
            layerOverBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            layerOverBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            layerOverBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            layerOverBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            
            userImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 150),
            userImageView.heightAnchor.constraint(equalToConstant: 150),
            userImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100),
            
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10),
            
            nameLabel.leadingAnchor.constraint(equalTo: layerOverBackgroundView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: layerOverBackgroundView.trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 15),
            
            muteButton.trailingAnchor.constraint(equalTo: layerOverBackgroundView.trailingAnchor),
            muteButton.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            muteButton.widthAnchor.constraint(equalToConstant: 40),
            muteButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    //MARK: - Actions
    @IBAction func didPressMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        didPressMuteButton?(sender.isSelected)
    }

    
}


class PlaceholderGenerator {
    //MARK: - Properties
    static let instance = PlaceholderGenerator()
    
    private lazy var cache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "QMUserPlaceholer.cache"
        cache.countLimit = 200
        return cache
    }()
    
    private let colors: [UIColor] = [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3035047352, green: 0.8693258762, blue: 0.4432001114, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.02297698334, green: 0.6430568099, blue: 0.603818357, alpha: 1), #colorLiteral(red: 0.5244195461, green: 0.3333674073, blue: 0.9113605022, alpha: 1), #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), #colorLiteral(red: 0.839125216, green: 0.871129334, blue: 0.3547145724, alpha: 1), #colorLiteral(red: 0.09088832885, green: 0.7803853154, blue: 0.8577881455, alpha: 1), #colorLiteral(red: 0.3175504208, green: 0.4197517633, blue: 0.7515394688, alpha: 1)]
    
    //MARK: - Class Methods
    class func color(index: Int) -> UIColor {
        return PlaceholderGenerator.instance.color(index: index)
    }
    
    class func placeholder(size: CGSize, title: String?) -> UIImage {
        let key = title ?? ""
        if let image = PlaceholderGenerator.instance.cache.object(forKey: key as AnyObject) as? UIImage {
            return image
        } else {
            let index = key.count % 10
            let image = placeholder(size: size,
                                    color: PlaceholderGenerator.instance.color(index: index),
                                    title: title,
                                    isOval: true)
            PlaceholderGenerator.instance.cache.setObject(image, forKey: key as AnyObject)
            return image
        }
    }
    
    class func placeholder(size: CGSize, color: UIColor, title: String?, isOval: Bool) -> UIImage {
        let minSize = min(size.width, size.height)
        let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let path = isOval ? UIBezierPath(ovalIn: frame) : UIBezierPath(rect: frame)
        color.setFill()
        path.fill()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let font = UIFont.systemFont(ofSize: minSize / 2.0)
        let textColor = UIColor.white
        let titleString = NSString(string: title ?? "Q")
        
        let textContent = titleString.substring(to: 1).uppercased()
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: textColor,
                                                         .paragraphStyle: paragraphStyle]
        
        let rect = textContent.boundingRect(with: frame.size,
                                            options: .usesLineFragmentOrigin,
                                            attributes: attributes,
                                            context: nil)
        
        let textRect = rect.offsetBy(dx: (size.width - rect.width) / 2.0,
                                     dy: (size.height - rect.height) / 2.0)
        
        textContent.draw(in: textRect, withAttributes: attributes)
        //Get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    class func rect(withIndex idx: Int, size: Int, count: Int) -> CGRect {
        let heightValue: Int = count > 2 ? size / 2 : size
        let widthValue: Int = size / 2
        
        switch idx {
        case 0:
            return CGRect(x: 0,
                          y: 0,
                          width: widthValue,
                          height: count < 4 ? size : size / 2)
        case 1:
            return CGRect(x: widthValue,
                          y: 0,
                          width: widthValue,
                          height: heightValue)
        case 2:
            return CGRect(x: count < 4 ? widthValue : 0,
                          y: widthValue,
                          width: widthValue,
                          height: heightValue)
        case 3:
            return CGRect(x: widthValue,
                          y: widthValue,
                          width: widthValue,
                          height: heightValue)
        default:
            return CGRect.zero
        }
    }
    
    //MARK: - Internal Methods
    private func color(index: Int) -> UIColor {
        let color = colors[index % colors.count]
        return color
    }
}


