//
//  Calendar2ViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 6/4/26.
//

import Foundation

class Calendar2ViewModel {
    
    @Published var selectedDate: Date?
    
    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    let calendar = Calendar(identifier: .gregorian)
    @Published var currentMonthData: [Date: Int] = [:]
    @Published var nextMonthData: [Date: Int] = [:]
    @Published var previousMonthData: [Date: Int] = [:]
    
    init() {
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
    
    func getDaysOfMonthDiaries(date: Date) {
        
    }
    
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
