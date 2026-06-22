//
//  CalendarConfig.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

struct CalendarConfig {
    var startDate: Date
    var endDate: Date
    
    var firstWeekday: Int
    
    
    //var cellHeight: CGFloat
    var cellInRowSpacing: CGFloat
    var rowsSpacing: CGFloat
    
    var weekDayTitlesRowHeight: CGFloat
    
    var sectionInset: NSDirectionalEdgeInsets
    
    static var `default`: CalendarConfig {
        CalendarConfig(
            startDate: Date().adding(months: -24).startOfMonth,
            endDate: Date().startOfMonth,
            firstWeekday: 0,
            cellInRowSpacing: 2,
            rowsSpacing: 2,
            weekDayTitlesRowHeight: 55,
            sectionInset: .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        )
    }
}
