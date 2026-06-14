//
//  WeekDayTitlesRowHeader.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

class WeekDayTitlesRowHeader: UICollectionReusableView {
    
    static let identifier = "WeekDayTitlesRowHeader"
    
    static let kind = "weekday-row"
    
    static var appearance: WeekDayTitlesAppearance = .default
    
    private let hStackView = UIStackView()
    private lazy var satLabel: UILabel = makeWeekDayLabel(text: "Sat")
    private lazy var sunLabel: UILabel = makeWeekDayLabel(text: "Sun")
    private lazy var monLabel: UILabel = makeWeekDayLabel(text: "Mon")
    private lazy var tueLabel: UILabel = makeWeekDayLabel(text: "Tue")
    private lazy var wedLabel: UILabel = makeWeekDayLabel(text: "Wed")
    private lazy var thuLabel: UILabel = makeWeekDayLabel(text: "Thu")
    private lazy var friLabel: UILabel = makeWeekDayLabel(text: "Fri")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayTitlesUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDayTitlesUI() {
        hStackView.axis = .horizontal
        hStackView.spacing = 0
        hStackView.alignment = .center
        hStackView.distribution = .fillEqually
        
        addSubview(hStackView)
        
        hStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [satLabel, sunLabel, monLabel, tueLabel, wedLabel, thuLabel, friLabel].forEach {
            hStackView.addArrangedSubview($0)
        }
    }
    
    private func makeWeekDayLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = Self.appearance.font
        label.textColor = Self.appearance.color
        label.textAlignment = .center
        label.text = text
        return label
    }
}
