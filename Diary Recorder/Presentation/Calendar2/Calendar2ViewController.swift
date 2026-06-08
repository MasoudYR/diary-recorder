//
//  Calendar2ViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 6/4/26.
//

import Foundation
import UIKit
import SnapKit
import JTAppleCalendar

class Calendar2ViewController: UIViewController {
    
    let viewModel: Calendar2ViewModel
    
    private var datePickerAndCalendarState: DatePickerAndCalendarState = .calendar {
        didSet {
            updateView()
        }
    }
    
    //    private var state: PlayingState = .idle {
    //        didSet {
    //            print(">>>", Self.self, #function, "state: \(state)")
    //            updateView()
    //        }
    //    }
    
    private let calendarPackView = UIView()
    private let monthYearButton = MonthYearButton()
    private let calendarAndPickerViewParentView = UIView()
    private let hStackView = UIStackView()
    private lazy var satLabel: UILabel = makeWeekDayLabel(text: "Sat")
    private lazy var sunLabel: UILabel = makeWeekDayLabel(text: "Sun")
    private lazy var monLabel: UILabel = makeWeekDayLabel(text: "Mon")
    private lazy var tueLabel: UILabel = makeWeekDayLabel(text: "Tue")
    private lazy var wedLabel: UILabel = makeWeekDayLabel(text: "Wed")
    private lazy var thuLabel: UILabel = makeWeekDayLabel(text: "Thu")
    private lazy var friLabel: UILabel = makeWeekDayLabel(text: "Fri")
    private let calendarView = JTACMonthView()
    private let monthYearPickerView = MonthYearPickerView()
    private let closeMonthYearPickerButton = UIButton()
    
    private let button: UIButton = .init(configuration: .filled())
    
    init(viewModel: Calendar2ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> Calendar2ViewController {
        let viewModel = Calendar2ViewModel()
        let viewController = Calendar2ViewController(viewModel: viewModel)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendar()
        calendarView.selectDates([.now])
        scrollToToday(animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .main
        setupCalendarPackView()
        setupMonthYearButton()
        setupCalendarAndPickerViewParentView()
        setupCalendarView()
        setupMonthYearPickerView()
    
        button.backgroundColor = .yellow
        button.setTitle("Today", for: .normal)
        button.layer.borderColor = UIColor.cyan.cgColor
        button.layer.borderWidth = 1
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 40))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(100)
        }
        
        let buttonAction = UIAction { [weak self] _ in
            guard let self else { return }
            scrollToToday()
    
            var dateComponents = DateComponents()
            dateComponents.year = 2026
            dateComponents.month = 5
            dateComponents.day = 1
            
            let oneMonthBefore = Calendar(identifier: .gregorian).date(from: dateComponents)
            
            viewModel.getDaysOfMonthDiaries(date: oneMonthBefore!)
        }
        
        button.addAction(buttonAction, for: .touchUpInside)
        
        updateView()
    }
    
    private func setupCalendarPackView() {
        calendarPackView.layer.borderColor = UIColor.systemGray.cgColor
        calendarPackView.layer.borderWidth = 1
        calendarPackView.layer.cornerRadius = 20
        calendarPackView.backgroundColor = .main
        
        view.addSubview(calendarPackView)
        
        calendarPackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    private func setupMonthYearButton() {
        calendarPackView.addSubview(monthYearButton)
        
        monthYearButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        let monthYearButtonActionIdentifier = UIAction.Identifier("monthYearButtonActionIdentifier")
        let monthYearButtonAction = UIAction(identifier: monthYearButtonActionIdentifier) { [unowned self] _ in
            print("this button tapped")
            //monthYearButton.setMonthYearTitle(monthYear: "auguest, 1992")
            datePickerAndCalendarState = .datePicker
        }
        
        monthYearButton.removeAction(identifiedBy: monthYearButtonActionIdentifier, for: .touchUpInside)
        monthYearButton.addAction(monthYearButtonAction, for: .touchUpInside)
    }
    
    private func setupCalendarAndPickerViewParentView() {
        calendarPackView.addSubview(calendarAndPickerViewParentView)
        calendarAndPickerViewParentView.backgroundColor = .green
        calendarAndPickerViewParentView.snp.makeConstraints { make in
            make.height.equalTo(300)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(monthYearButton.snp.bottom)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupCalendarView() {
        hStackView.axis = .horizontal
        hStackView.spacing = 0
        hStackView.alignment = .center
        hStackView.distribution = .fillEqually
        
        calendarAndPickerViewParentView.addSubview(hStackView)
        
        hStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            //make.height.equalTo(30)
        }
        
        [satLabel, sunLabel, monLabel, tueLabel, wedLabel, thuLabel, friLabel].forEach {
            hStackView.addArrangedSubview($0)
        }
        
        calendarAndPickerViewParentView.addSubview(calendarView)
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(hStackView.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
            //make.height.equalTo(250)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupMonthYearPickerView() {
        monthYearPickerView.backgroundColor = .white
        monthYearPickerView.delegate = self
        
        calendarAndPickerViewParentView.addSubview(monthYearPickerView)

        monthYearPickerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        monthYearPickerView.select(month: 1, year: 2026)
        
        
        closeMonthYearPickerButton.tintColor = .label
        let symbolConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        closeMonthYearPickerButton.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfigure), for: .normal)
        
        calendarAndPickerViewParentView.addSubview(closeMonthYearPickerButton)
        
        closeMonthYearPickerButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.size.equalTo(40)
            make.right.equalToSuperview().inset(5)
        }
        
        let closeMonthYearPickerButtonActionIdentifier = UIAction.Identifier("closeMonthYearPickerButtonActionIdentifier")
        let closeMonthYearPickerButtonAction = UIAction(identifier: closeMonthYearPickerButtonActionIdentifier) { [unowned self] _ in
            print("closeeee button tapped")
            datePickerAndCalendarState = .calendar
        }
        
        closeMonthYearPickerButton.removeAction(identifiedBy: closeMonthYearPickerButtonActionIdentifier, for: .touchUpInside)
        closeMonthYearPickerButton.addAction(closeMonthYearPickerButtonAction, for: .touchUpInside)
    }
    
    private func setupCalendar() {
        //let mainCalendar = Calendar(identifier: .gregorian)
        calendarView.backgroundColor = UIColor(resource: .omid) //(named: "MainColor")
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.isPagingEnabled = true
        calendarView.minimumLineSpacing = 5
        calendarView.minimumInteritemSpacing = 0
        calendarView.allowsMultipleSelection = false
        calendarView.allowsRangedSelection = false
        calendarView.register(CalendarDateCell.self, forCellWithReuseIdentifier: CalendarDateCell.identifier)
        calendarView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.identifier)
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
    }
    
    private func makeWeekDayLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.roundedFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.text = text
        return label
    }
    
    private func updateView() {
        if datePickerAndCalendarState == .calendar {
            hStackView.isHidden = false
            calendarView.isHidden = false
            monthYearPickerView.isHidden = true
            closeMonthYearPickerButton.isHidden = true
            monthYearButton.isEnabled = true
            monthYearButton.buttonState = .calendar
        } else {
            hStackView.isHidden = true
            calendarView.isHidden = true
            monthYearPickerView.isHidden = false
            closeMonthYearPickerButton.isHidden = false
            monthYearButton.isEnabled = false
            monthYearButton.buttonState = .datePicker
        }
    }
    
    
}

extension Calendar2ViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        
        let firstDate = Calendar.current.date(from: components)!
        
        components.year = 2222
        let endDate = Calendar.current.date(from: components)!
        return ConfigurationParameters(
            startDate: firstDate,
            endDate: endDate,
            numberOfRows: 6,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .saturday,
            
        )
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        if cellState.dateBelongsTo != .thisMonth {
            return calendar.dequeueReusableJTAppleCell(withReuseIdentifier: EmptyCell.identifier, for: indexPath)
        }
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarDateCell.identifier, for: indexPath) as! CalendarDateCell
        configure(cell: cell, date: date, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
        guard let cell = cell as? CalendarDateCell else { return }
        
        configure(cell: cell, date: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        print(">>>", Self.self, #function, type(of: cell))
        
        return cell is CalendarDateCell
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? CalendarDateCell else { return }
        
        configure(cell: cell, date: date, cellState: cellState)
        
        
        viewModel.selectDate(date: date)
        
        print(">>>", Self.self, #function, "this date is selected: \(date)")
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? CalendarDateCell else { return }
        
        configure(cell: cell, date: date, cellState: cellState)
        
        print("this date is deselected: \(date)")
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        print(">>>", Self.self, #function, ">", visibleDates.monthDates.first!.date)
        guard let date = visibleDates.monthDates.first?.date else { return }
        let monthYearString = viewModel.transformDateToMonthAndYear(date: date)
        monthYearButton.setMonthYearTitle(monthYear: monthYearString)
        //viewModel.getDaysOfMonthDiaries(date: date)
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        print(">>>", Self.self, #function, ">", visibleDates.monthDates.first!.date)
        guard let date = visibleDates.monthDates.first?.date else { return }
        viewModel.getDaysOfMonthDiaries(date: date)
    }
    
    func scrollToToday(animated: Bool = true) {
        let today = Date()
        
        calendarView.scrollToDate(
            today,
            animateScroll: animated,
            extraAddedOffset: 0
        )
        
        // اختیاری: انتخاب خودکار امروز
        //calendarView.calendar.selectDates([today])
    }
    
//    func scrollToMonthFirstDay(date: Date, animated: Bool = false) {
//        calendarView.scrollToDate(date)
//    }
    
    
    private func configure(cell: JTACDayCell, date:  Date, cellState: CellState) {
        guard let cell = cell as? CalendarDateCell else { return }
        
        let isSelected = cellState.isSelected
        let isToday = Calendar.current.isDateInToday(date)
        //let isOutMonth = cellState.dateBelongsTo != .thisMonth
        
        cell.configure(
            dayNumber: cellState.text,
            decorateBadgeText: "5",
            decorateBadgeColor: .orange,
            isSelected: isSelected,
            isToday: isToday
        )
    }
    
}


extension Calendar2ViewController: MonthYearPickerViewDelegate {
    
    func monthYearPickerView(_ picker: MonthYearPickerView, didSelect month: Int, year: Int) {

        var components = DateComponents(year: year, month: month)
        components.day = 1
        
        guard let date = Calendar.current.date(from: components) else { return }
        calendarView.scrollToDate(date)
        //self.calendarView.select(date)
    }
    
    
    
}

enum DatePickerAndCalendarState {
    case datePicker
    case calendar
}
