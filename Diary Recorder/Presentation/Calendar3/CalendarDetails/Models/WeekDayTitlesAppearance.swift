//
//  WeekDayTitlesAppearance.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

struct WeekDayTitlesAppearance {
    var font: UIFont
    var color: UIColor
    var spaceBetweenWeekDays: CGFloat = 0
    
    static var `default`: WeekDayTitlesAppearance {
        .init(
            font: UIFont.roundedFont(ofSize: 18, weight: .semibold),
            color: UIColor.label,
            spaceBetweenWeekDays: 0
        )
    }
}
