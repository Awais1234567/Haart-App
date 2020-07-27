//
//  StatsView.swift
//  Haart App
//
//  Created by Awais Khalid on 25/07/2020.
//  Copyright © 2020 TalhaShah. All rights reserved.
//

import Foundation
struct StatsViewConstants {
    static let statsReportPlaceholderText = "Loading stats report..."
}

class StatsView: UIView {
    //MARK: - Properties
    lazy private var statsLabel: UILabel = {
        let statsLabel = UILabel(frame: bounds)
        statsLabel.text = StatsViewConstants.statsReportPlaceholderText
        statsLabel.numberOfLines = 0
        statsLabel.font = UIFont(name: "Roboto", size: 12.0)
        statsLabel.adjustsFontSizeToFitWidth = true
        statsLabel.minimumScaleFactor = 0.6
        statsLabel.textColor = UIColor.green
        return statsLabel
    }()
    
    override var isHidden: Bool {
        didSet {
            if isHidden == true {
                updateStats(nil)
            }
        }
    }
    
    //MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(statsLabel)
        backgroundColor = UIColor(white: 0.0, alpha: 0.6)
    }
    
    override func layoutSubviews() {
        statsLabel.frame = bounds
    }
    
    //MARK: - Internal Methods
    func updateStats(_ stats: String?) {
        statsLabel.text = stats ?? StatsViewConstants.statsReportPlaceholderText
    }
}


