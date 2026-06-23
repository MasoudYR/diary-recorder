//
//  CalendarMonth.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation

struct CalendarMonth: Hashable {
    let id: String     // "2026-01"
    let title: String
    let firstDay: Date
    let numberOfWeeks: Int
    var days: [CalendarDay]
    
}
