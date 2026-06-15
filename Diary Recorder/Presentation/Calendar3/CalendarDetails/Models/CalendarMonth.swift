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
    let days: [CalendarDay]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
