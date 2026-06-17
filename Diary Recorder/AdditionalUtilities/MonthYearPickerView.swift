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
    
    private let months: [String] = Calendar.current.monthSymbols
    private var years: [Int] = []
    
    private var startDate: Date
    private var endDate: Date
    
    private(set) var selectedMonth: Int = 1
    private(set) var selectedYear: Int = 2026
    
    private var pickerView = UIPickerView()
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        super.init(frame: .zero)
        setupYears()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupYears() {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)
        years = Array(startYear...endYear)
    }
    
    private func setupUI() {
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollToCurrentDate(animated: false)
    }
    
    func select(month: Int, year: Int, animated: Bool = false) {
        selectedMonth = month
        selectedYear = year
        scrollToCurrentDate(animated: true)
    }
    
    private func scrollToCurrentDate(animated: Bool) {
        pickerView.selectRow(selectedMonth - 1, inComponent: 0, animated: animated)
        
        if let yearIndex = years.firstIndex(of: selectedYear) {
            pickerView.selectRow(yearIndex, inComponent: 1, animated: animated)
        }
    }
}

extension MonthYearPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? months.count : years.count
    }
}

extension MonthYearPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = .roundedFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = component == 0 ? months[row] : String(years[row])
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        45
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        component == 0 ? 100 : 100
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedMonth = row + 1
        } else {
            selectedYear = years[row]
        }
        
        delegate?.monthYearPickerView(self, didSelect: selectedMonth, year: selectedYear)
    }
}
    
 
