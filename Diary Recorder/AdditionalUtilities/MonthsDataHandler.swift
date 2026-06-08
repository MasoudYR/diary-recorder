//
//  MonthsDataHandler.swift
//  Diary Recorder
//
//  Created by Masoud on 6/8/26.
//

import Foundation

final class MonthsDataHandler: AnyObject {
    let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    let calendar = Calendar(identifier: .gregorian)
    //var monthsHasGottenData: [Date] = []
    var currentMonthData: [Date: Int] = [:]
    var nextMonthData: [Date: Int] = [:]
    var previousMonthData: [Date: Int] = [:]
    
    func loadMonthData(date: Date) {
        
        var currentMonthComponents = calendar.dateComponents([.year, .month], from: date)
        currentMonthComponents.day = 1
        
        guard let firstDayOfCurrentMonth = calendar.date(from: currentMonthComponents),
        let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfCurrentMonth),
        let firstDayOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth)
        else { return }
        
        let currentMonthResult = try? recordingsDetailsRealmManager.getNumberOfDaysRecordsInMonth(date: firstDayOfCurrentMonth)
        let nextMonthResult = try?
        recordingsDetailsRealmManager.getNumberOfDaysRecordsInMonth(date: firstDayOfNextMonth)
        let previousMonthResult = try?
        recordingsDetailsRealmManager.getNumberOfDaysRecordsInMonth(date: firstDayOfPreviousMonth)
        
        currentMonthData = currentMonthResult ?? [:]
        nextMonthData = nextMonthResult ?? [:]
        previousMonthData = previousMonthResult ?? [:]
    }

}
