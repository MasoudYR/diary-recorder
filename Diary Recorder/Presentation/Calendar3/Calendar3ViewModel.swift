//
//  Calendar3ViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import Combine

class Calendar3ViewModel {
    
    @Published private(set) var months: [CalendarMonth] = []
    @Published var selectedDate: Date? = nil
    
    @Published var config: CalendarConfig {
        didSet{ rebuild() }
    }
    
//    var selectionPublisher: AnyPublisher<Date?, Never> {
//        $selectedDate.eraseToAnyPublisher()
//    }
    
    private var calendar = Calendar.current
    
    
    init(config: CalendarConfig = .default) {
        self.config = config
        setupCalendar()
        rebuild()
    }
    
    func isSelected(_ day: CalendarDay) -> Bool {
        guard let sel = selectedDate else { return false }
        return calendar.isDate(sel, inSameDayAs: day.date)
    }
    
    func update(startDate: Date? = nil, endDate: Date? = nil) {
        if let s = startDate {
            config.startDate = s
        }
        
        if let e = endDate {
            config.endDate = e
        }
    }
    
    private func setupCalendar() {
        calendar.firstWeekday = config.firstWeekday
    }
    
    private func rebuild() {
        calendar.firstWeekday = config.firstWeekday
        
        var result: [CalendarMonth] = []
        var cursor = config.startDate.startOfMonth
        let last = config.endDate.endOfMonth
        
        while cursor <= last {
            result.append(buildMonth(cursor))
            cursor = cursor.adding(months: 1)
        }
        
        months = result
    }
    
    private func buildMonth(_ firstDay: Date) -> CalendarMonth {
        
        let totalCells = 42
        
        let rawWeekDay = calendar.component(.weekday, from: firstDay)
        
        // تفاوت اولین روز هفته با اولین روز ماه رو بدست میاره برای جلوگیری از عدد منفی با هفت جمع میکنه. و تقسیم به هفت میکنه تا بفهمه قبل از شروع اولین روز ماه چند روز هفته خالی خواهد بود!
        let leadingCount = (rawWeekDay - calendar.firstWeekday + 7) % 7
        
        // محاسبه تعداد روزهای این ماه متعلق به روز گرفته شده چند روز است.
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)!.count
        
        // محاسبه تعداد روزهای خالی انتهای ماه
        let trailingCount = totalCells - leadingCount - daysInMonth
        
        var days: [CalendarDay] = []
        
        //محاسبه تعداد روزهای ماه قبل که کنار روزهای این ماه نمایش داده میشه.
        let prevFirst = firstDay.adding(months: -1)
        let daysInPrev = calendar.range(of: .day, in: .month, for: prevFirst)!.count
        
        for i in stride(from: leadingCount, through: 1, by: -1) {
            let d = daysInPrev - i + 1
            let date = dateFor(year: prevFirst.year, month: prevFirst.month, day: d)
            days.append(makeDay(date: date, isCurrentMonth: false))
        }
        
        //محاسبه رمزهای ماه جاری
        for d in 1...daysInMonth {
            let date = dateFor(year: firstDay.year, month: firstDay.month, day: d)
            days.append(makeDay(date: date, isCurrentMonth: true))
        }
        
        // محاسبه روزهای ماه بعدی فکر میکنم چون ممکنه تعداد روزهای ماه بعدی از این ماه بیشتر از یک هفته باشد(‌در تعداد کل ۴۲ تایی. پس باقیمانده تقسیم به ۷ را ازش محاسبه میکنم تا فقط روزهای انتهایی بماند تا آخرین روز از آخرین هفته این ماه.
        let nextFirst = firstDay.adding(months: 1)
        if trailingCount % 7 > 0 {
            for d in 1...max(1, (trailingCount % 7) ) {
                let date = dateFor(year: nextFirst.year, month: nextFirst.month, day: d)
                days.append(makeDay(date: date, isCurrentMonth: false))
            }
        }
        
        let numberOfWeeks = days.count / 7
        
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        let title = fmt.string(from: firstDay)

        return CalendarMonth(
            id: firstDay.monthId,
            title: title,
            firstDay: firstDay,
            numberOfWeeks: numberOfWeeks,
            days: days
        )
        
    }
    
    private func makeDay(date: Date, isCurrentMonth: Bool) -> CalendarDay {
        let weekday = calendar.component(.weekday, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        return CalendarDay(
            id: date.dayId,
            date: date,
            dayNumber: date.day,
            isCurrentMonth: isCurrentMonth,
            isToday: calendar.isDateInToday(date),
            isWeekend: isWeekend
        )
    }
    
    private func dateFor(year: Int, month: Int, day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        return calendar.date(from: c)!
    }
}

