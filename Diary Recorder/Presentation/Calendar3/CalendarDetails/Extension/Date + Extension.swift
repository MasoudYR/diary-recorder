//
//  Date + Extension.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation

extension Date {
    
    var startOfMonth: Date {
        let c = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: c)!
    }
    
    var endOfMonth: Date {
        var c = DateComponents()
        c.month = 1
        c.day = -1
        return Calendar.current.date(byAdding: c, to: startOfMonth)!
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var dayId: String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
    
    var monthId: String {
        let c = Calendar.current.dateComponents([.year, .month], from: self)
        return String(format: "%04d-%02d", c.year!, c.month!)
    }
    
    func adding(months n: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: n, to: self)!
    }
    
    func adding(days n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
    
    func transformDateToMonthAndYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        let monthYearString = formatter.string(from: self)
        
        return monthYearString
    }
    
}
