//
//  MonthYearPickerView.swift
//  Diary Recorder
//
//  Created by Masoud on 6/6/26.
//

import Foundation
import UIKit
import SnapKit

protocol MonthYearPickerViewDelegate: AnyObject {
    func monthYearPickerView(_ picker: MonthYearPickerView, didSelect month: Int, year: Int)
}

final class MonthYearPickerView: UIView {
    
    weak var delegate: MonthYearPickerViewDelegate?

    private(set) var selectedMonth: Int
    private(set) var selectedYear: Int
    
    private var currentYearIndex: Int = 0
    
    private var yearMonthData: [YearMonthsData] = []
    
    private var startDate: Date
    private var endDate: Date
    
    private var pickerView = UIPickerView()
    
    private static let monthNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.selectedYear = startDate.year
        self.selectedMonth = startDate.month
        super.init(frame: .zero)
        prepareData(startDate: startDate, endDate: endDate)
        setupUI()
        select(month: startDate.month, year: startDate.year, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollToSelectedDate(animated: false)
    }
    
    func setDateRange(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.selectedYear = startDate.year
        self.selectedMonth = startDate.month
        
        prepareData(startDate: startDate, endDate: endDate)
        pickerView.reloadAllComponents()
        scrollToSelectedDate(animated: false)
    }
    
    func select(month: Int, year: Int, animated: Bool = false) {
        selectedMonth = month
        selectedYear = year
        scrollToSelectedDate(animated: false)
    }
    
    private func prepareData(startDate: Date, endDate: Date) {
        let calendar = Calendar(identifier: .gregorian)
        var result: [YearMonthsData] = []
        
        var current = startDate.startOfMonth
        let end = endDate.startOfMonth
        
        while current <= end {
            let year = calendar.component(.year, from: current)
            let month = calendar.component(.month, from: current)
            
            if let existing = result.firstIndex(where: {$0.year == year}) {
                result[existing].months.append(month)
            } else {
                result.append(YearMonthsData(year: year, months: [month]))
            }
            
            let next = current.adding(months: 1)
            current = next
        }
        
        self.yearMonthData = result
    }
    
    private func scrollToSelectedDate(animated: Bool) {
        guard let yearIndex = yearMonthData.firstIndex(where: { $0.year == selectedYear}) else { return }
        
        currentYearIndex = yearIndex
        pickerView.selectRow(yearIndex, inComponent: 1, animated: animated)
        pickerView.reloadComponent(0)
        
        if let monthIndex = yearMonthData[yearIndex].months.firstIndex(of: selectedMonth) {
            pickerView.selectRow(monthIndex, inComponent: 0, animated: animated)
        }
    }
    
    private func monthNameBuilder(month: Int) -> String {
        var components = DateComponents()
        components.month = month
        
        guard let date = Calendar.current.date(from: components) else { return "ماه \(month)" }
        
        return  Self.monthNameFormatter.string(from: date)
    }
    
}

extension MonthYearPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print(">>????>", pickerView.numberOfComponents)
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            guard currentYearIndex < yearMonthData.count else { return 0 }
            return yearMonthData[currentYearIndex].months.count
        } else {
            return yearMonthData.count
        }
    }
}

extension MonthYearPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = .roundedFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        
        if component == 0 {
            guard currentYearIndex < yearMonthData.count else { return label }
            let month = yearMonthData[currentYearIndex].months[row]
            label.text = monthNameBuilder(month: month)
        } else {
            label.text = String(yearMonthData[row].year)
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        45
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        100
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 1 {
            currentYearIndex = row
            pickerView.reloadComponent(0)
        }
        
        let monthIndex = pickerView.selectedRow(inComponent: 0)
        guard currentYearIndex < yearMonthData.count,
              monthIndex < yearMonthData[currentYearIndex].months.count else { return }
        
        selectedYear = yearMonthData[currentYearIndex].year
        selectedMonth = yearMonthData[currentYearIndex].months[monthIndex]
        
        delegate?.monthYearPickerView(self, didSelect: selectedMonth, year: selectedYear)
    }
}
    
struct YearMonthsData {
    let year: Int
    var months: [Int]
}
