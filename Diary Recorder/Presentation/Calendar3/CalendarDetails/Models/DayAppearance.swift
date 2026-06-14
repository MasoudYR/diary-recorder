//
//  DayAppearance.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

struct DayAppearance {
    
    var normalFont: UIFont
    var normalColor: UIColor
    var normalBackgroundColor: UIColor
    var normalBadgeNum: Int
    
    var todayFont: UIFont
    var todayColor: UIColor
    var todayBackgroundColor: UIColor
    var todayBadgeNum: Int
    
    var selectedFont: UIFont
    var selectedColor: UIColor
    var selectedBackgroundColor: UIColor
    var selectedBadgeNum: Int
    
    //var refrenceCellHeight: CGFloat
    
    var cornerRadius: CGFloat
    
    var badgeFontSize: CGFloat
    
    static var `default`: DayAppearance {
        .init(
            normalFont: .roundedFont(ofSize: 18, weight: .semibold),
            normalColor: .label,
            normalBackgroundColor: .clear,
            normalBadgeNum: 0,
            
            todayFont: .roundedFont(ofSize: 18, weight: .semibold),
            todayColor: .label,
            todayBackgroundColor: .clear,
            todayBadgeNum: 0,
            
            selectedFont: .roundedFont(ofSize: 18, weight: .semibold),
            selectedColor: .systemBlue,
            selectedBackgroundColor: .main,
            selectedBadgeNum: 0,
            
           // weekendColor: .label,
            
           // refrenceCellHeight: 44,
            cornerRadius: 20,
            badgeFontSize: 10,
            )
    }
}
