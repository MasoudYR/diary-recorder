//
//  MonthYearButton.swift
//  Diary Recorder
//
//  Created by Masoud on 6/6/26.
//

import Foundation
import UIKit
import SnapKit

class MonthYearButton: UIButton {
    
    private let buttonLabel = UILabel()
    private let buttonImageView = UIImageView()
    
    var buttonState: DatePickerAndCalendarState = .calendar {
        didSet {
            buttonStateUpdateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        buttonLabel.text = "Month, Year"
        buttonLabel.font = UIFont.roundedFont(ofSize: 25, weight: .bold)
        buttonLabel.textColor = .label
        buttonLabel.textAlignment = .left
        //buttonLabel.backgroundColor = .red
        
        addSubview(buttonLabel)
        
        buttonLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        let symbolConfigue = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        buttonImageView.image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfigue)
        buttonImageView.tintColor = .label
        buttonImageView.backgroundColor = .magenta
        
        addSubview(buttonImageView)
        
        buttonImageView.snp.makeConstraints { make in
            //make.size.equalTo(20)
            make.left.equalTo(buttonLabel.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    func setMonthYearTitle(monthYear: String) {
        buttonLabel.text = monthYear
    }
    
    private func buttonStateUpdateView() {
        let symbolConfigue = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        if  buttonState == .calendar {
            buttonImageView.image = UIImage(systemName: "chevron.right", withConfiguration: symbolConfigue)
        } else {
            buttonImageView.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfigue)
        }
    }
}
