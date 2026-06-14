//
//  MonthsDataHandler.swift
//  Diary Recorder
//
//  Created by Masoud on 6/8/26.
//

import Foundation
import Combine

final class MonthsDataHandler: AnyObject {
    
    static let shared = MonthsDataHandler()
    
    private init() {}
    
    let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    let calendar = Calendar(identifier: .gregorian)
    var dataCache: [YearMonth: [Date: Int]] = [:]
    
    func loadMonthDataCache(date: Date) {
    
        let today = Date()
        
        let firstDayOfCurrentMonth = makeFirstDayOfMonth(from: date)
        let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfCurrentMonth)!
        let firstDayOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth)!

        let yearCurrentMonth = makeYearMonthStructure(from: firstDayOfCurrentMonth)
        let yearNextMonth = makeYearMonthStructure(from: firstDayOfNextMonth)
        let yearPreviousMonth = makeYearMonthStructure(from: firstDayOfPreviousMonth)
        
        if !dataCache.keys.contains(yearCurrentMonth),
           firstDayOfCurrentMonth <= today {
            
            getMonthDataFromRealm(date: firstDayOfCurrentMonth, yearMonth: yearCurrentMonth)
        }
        
        if !dataCache.keys.contains(yearNextMonth),
           firstDayOfNextMonth <= today {
            
            getMonthDataFromRealm(date: firstDayOfNextMonth, yearMonth: yearNextMonth)
        }
        
        if !dataCache.keys.contains(yearPreviousMonth),
           firstDayOfPreviousMonth <= today {
            
            getMonthDataFromRealm(date: firstDayOfPreviousMonth, yearMonth: yearPreviousMonth)
        }
    }
    
    func updateData(date: Date) {
        
        let yearMonth = makeYearMonthStructure(from: date)
        let numberOfRecords = try! recordingsDetailsRealmManager.getNumberOfRecordsInOneDay(date: date)
        
        dataCache[yearMonth] = [date: numberOfRecords]
    }
    
    func makeYearMonthStructure(from date: Date) -> YearMonth {
        let components = calendar.dateComponents([.year, .month], from: date)
        return YearMonth(year: components.year!, month: components.month!)
    }
    
    func makeThreeContinuesMonths(from date: Date) -> ThreeMonthsOfOneDate {
        
        let firstDayOfCurrentMonth = makeFirstDayOfMonth(from: date)
        let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfCurrentMonth)!
        let firstDayOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth)!
        
        let previous = makeYearMonthStructure(from: firstDayOfPreviousMonth)
        let current = makeYearMonthStructure(from: firstDayOfCurrentMonth)
        let next = makeYearMonthStructure(from: firstDayOfNextMonth)
        
        return ThreeMonthsOfOneDate(previousMonth: previous, currentMonth: current, nextMonth: next)
    }
    
    private func getMonthDataFromRealm(date: Date, yearMonth: YearMonth) {
        let currentMonthResult = try! recordingsDetailsRealmManager.getNumberOfDaysRecordsInMonth(date: date)
        dataCache[yearMonth] = currentMonthResult
    }
    
    func makeFirstDayOfMonth(from date: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = 1
        return calendar.date(from: components)!
    }
    

}

struct ThreeMonthsOfOneDate {
    let previousMonth: YearMonth
    let currentMonth: YearMonth
    let nextMonth: YearMonth
}

struct YearMonth: Hashable {
    let year: Int
    let month: Int
}
