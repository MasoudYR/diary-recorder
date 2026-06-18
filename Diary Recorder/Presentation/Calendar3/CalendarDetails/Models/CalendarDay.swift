//
//  CalendarDay.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation

struct CalendarDay: Hashable {
    let id: String    // "2026-01-01"
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
}
