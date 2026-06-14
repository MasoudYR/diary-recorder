//
//  Calendar2ViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 6/4/26.
//

import Foundation

class Calendar2ViewModel {
    
    let dataHandler = MonthsDataHandler.shared
    
    @Published var selectedDate: Date?
    
    
    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    let calendar = Calendar(identifier: .gregorian)
    let threeMonthsOfYear: [YearMonth] = []
    
    init() {
        let date = Date()
        
        for num in -10 ... -2 {
            let newDate = calendar.date(byAdding: .month, value: num, to: date)!
                .addingTimeInterval(3 * 86400)
            
            try? recordingsDetailsRealmManager.saveRecording(RecordingFileDetails(id: UUID(), fileName: "dodooleali.m4a", name: "doddol", date: newDate, duration: 5))
            try? recordingsDetailsRealmManager.saveRecording(RecordingFileDetails(id: UUID(), fileName: "dodooleali.m4a", name: "doddol", date: newDate, duration: 5))
            try? recordingsDetailsRealmManager.saveRecording(RecordingFileDetails(id: UUID(), fileName: "dodooleali.m4a", name: "doddol", date: newDate, duration: 5))
            try? recordingsDetailsRealmManager.saveRecording(RecordingFileDetails(id: UUID(), fileName: "dodooleali.m4a", name: "doddol", date: newDate, duration: 5))
        }
    
    }
    
    private func binding() {
        
    }
    
    func transformDateToMonthAndYear(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        let monthYearString = formatter.string(from: date)
        
        return monthYearString
    }
    
    func selectDate(date: Date) {
        selectedDate = date
        loadDiaryOfSelectedDate()
    }
    
    private func loadDiaryOfSelectedDate() {
        //
    }
    
    func loadThreeMonthsDataInCache(date: Date) {
        dataHandler.loadMonthDataCache(date: date)
    }
    
    func threeMonthsOfYearData(date: Date) -> [YearMonth: [Date: Int]?] {
        let threeMonths = dataHandler.makeThreeContinuesMonths(from: date)
        
        let previousMonthData = dataHandler.dataCache[threeMonths.previousMonth]
        let currentMonthData = dataHandler.dataCache[threeMonths.currentMonth]
        let nextMonthData = dataHandler.dataCache[threeMonths.nextMonth]
        
        return [
            threeMonths.previousMonth: previousMonthData,
            threeMonths.currentMonth: currentMonthData,
            threeMonths.nextMonth: nextMonthData
        ]
    }
    
    private var bool = true
    func counter(for date: Date) -> Int {
        if bool {
            print(">>>", #function, "data:", dataHandler.dataCache)
            bool.toggle()
        }
        
        let omid = dataHandler.makeYearMonthStructure(from: date)
        print(">>>", #function, "date: \(date)")
        guard let month = dataHandler.dataCache[omid] else { return 0 }
        
        return month[date, default: 0]
    }
}
