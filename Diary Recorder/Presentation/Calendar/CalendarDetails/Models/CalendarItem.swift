//
//  CalendarItem.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation

enum CalendarItem: Hashable {
    case day(CalendarDay)
    case outMonthDay(CalendarDay)
//    case noEntryDay
//    case haveEntryDay(Int)
}
