//
//  CalendarView.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit
import SnapKit
import Combine

final class CalendarView: UIView {
    
    weak var delegate: CalendarViewDelegate?
    weak var dataSource: CalendarViewDataSource?
    
    let viewModel: CalendarViewViewModel
    
    var config: CalendarConfig {
        get {viewModel.config}
        set {viewModel.config = newValue}
    }
    
    private var datePickerAndCalendarState: DatePickerAndCalendarState = .calendar {
        didSet {
            updateView()
        }
    }
    
    private var atFirstShowOfCalendarView: Bool = true
    
    private let monthYearButton = MonthYearButton()
    private let todayButton = UIButton()
    private let calendarAndPickerViewParentView = UIView()
    private let weekDayHeaderView = WeekDayTitlesRowHeader()
    private(set) lazy var collectionView: UICollectionView = makeCollectionView()
    private lazy var monthYearPickerView = MonthYearPickerView(startDate: config.startDate, endDate: config.endDate)
    private let closeMonthYearPickerButton = UIButton()
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<CalendarSection, CalendarItem>!
    
    let diffableDataSourceActionPassthroughSubject = PassthroughSubject<DiffableDataSourceActionAndData, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(config: CalendarConfig = .default) {
        self.viewModel = CalendarViewViewModel(config: config)
        super.init(frame: .zero)
        setupMonthYearButton()
        setupTodayButton()
        setupCalendarAndPickerView()
        setupWeekDayHeader()
        setupCollectionView()
        setupMonthYearPickerView()
        buildDiffableDataSource()
        bindViewModel()
        updateView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMonthYearButton() {
        addSubview(monthYearButton)
        
        monthYearButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }
        
        let monthYearButtonActionIdentifier = UIAction.Identifier("monthYearButtonActionIdentifier")
        let monthYearButtonAction = UIAction(identifier: monthYearButtonActionIdentifier) { [unowned self] _ in
            print("this button tapped")
            datePickerAndCalendarState = .datePicker

            let collectionVisibleMonth =  viewModel.months[getCurrentVisibleSection()]
            let month = collectionVisibleMonth.firstDay.month
            let year = collectionVisibleMonth.firstDay.year

            monthYearPickerView.select(month: month, year: year)
        }
        
        monthYearButton.removeAction(identifiedBy: monthYearButtonActionIdentifier, for: .touchUpInside)
        monthYearButton.addAction(monthYearButtonAction, for: .touchUpInside)
    }
    
    private func setupTodayButton() {
        todayButton.setTitle("Today", for: .normal)
        todayButton.titleLabel?.font = UIFont.roundedFont(ofSize: 15, weight: .regular)
        todayButton.setTitleColor(.label, for: .normal)
        todayButton.tintColor = .label
        todayButton.layer.cornerRadius = 15
        todayButton.layer.backgroundColor = UIColor.main.cgColor
        todayButton.layer.borderColor = UIColor.label.cgColor
        todayButton.layer.borderWidth = 1
        
        addSubview(todayButton)
        
        todayButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(monthYearButton)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        let todayButtonActionIdentifier = UIAction.Identifier("todayButtonActionIdentifier")
        let todayButtonAction = UIAction(identifier: todayButtonActionIdentifier) { [unowned self] _ in
            print("todayButton tapped")
            scrollToToday()
        }
        
        todayButton.removeAction(identifiedBy: todayButtonActionIdentifier, for: .touchUpInside)
        todayButton.addAction(todayButtonAction, for: .touchUpInside)
    }
    
    private func setupCalendarAndPickerView() {
       addSubview(calendarAndPickerViewParentView)
        calendarAndPickerViewParentView.backgroundColor = .systemBackground
        calendarAndPickerViewParentView.snp.makeConstraints { make in
            make.top.equalTo(monthYearButton.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupWeekDayHeader() {
        calendarAndPickerViewParentView.addSubview(weekDayHeaderView)
        weekDayHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(config.sectionInset.leading)
            make.trailing.equalToSuperview().inset(config.sectionInset.trailing)
            make.height.equalTo(config.weekDayTitlesRowHeight)
        }
    }
    
    private func setupCollectionView() {
        calendarAndPickerViewParentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekDayHeaderView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setupMonthYearPickerView() {
        monthYearPickerView.backgroundColor = .systemBackground
        monthYearPickerView.delegate = self
        
        calendarAndPickerViewParentView.addSubview(monthYearPickerView)

        monthYearPickerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        closeMonthYearPickerButton.tintColor = .label
        let symbolConfigure = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        closeMonthYearPickerButton.setImage(UIImage(systemName: "checkmark", withConfiguration: symbolConfigure), for: .normal)
        
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
    
    private func updateView() {
        let flag = datePickerAndCalendarState == .calendar
        weekDayHeaderView.isHidden = !flag
        collectionView.isHidden = !flag
        monthYearPickerView.isHidden = flag
        closeMonthYearPickerButton.isHidden = flag
        monthYearButton.isEnabled = flag
        todayButton.isHidden = !flag
        monthYearButton.buttonState = flag ? .calendar : .datePicker
    }
    
    private func buildDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<CalendarSection, CalendarItem>(collectionView: collectionView) { [weak self]
            collectionView, indexPath, item in
            guard let self else { return EmptyCell() }
            
            print(">>>", Self.self, #function, "indexPath: \(indexPath)")
            
            switch item {
            case .day(let day):
                let isSelected = self.viewModel.isSelected(day)
                
                if let custom = self.dataSource?.calendarView(
                    self,
                    cellFor: day,
                    isSelected: isSelected,
                    collectionView: collectionView,
                    indexPath: indexPath
                ) { return custom }
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DayCell.identifier,
                    for: indexPath
                ) as! DayCell
                
                cell.configure(
                    day: day,
                    isToday: day.isToday,
                    isSelected: isSelected,
                    isOutOfMonth: !day.isCurrentMonth,
                    badgeNum: day.numberOfDiaries
                )
                return cell
                
            case .outMonthDay(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.identifier, for: indexPath) as! EmptyCell
                return cell
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.$months
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] months in
                guard let self else { return }
                self.applySnapshot(months: months)
            }
            .store(in: &cancellables)
        
        bindDiffableDataSourceActions()
    }
    
    private func applySnapshot(months: [CalendarMonth]) {
        
        var newSnapshot = NSDiffableDataSourceSnapshot<CalendarSection, CalendarItem>()
        
        for month in months {
            let section = CalendarSection.month(month)
            newSnapshot.appendSections([section])
            
            let items: [CalendarItem] = month.days.map { day in
                
                if !day.isCurrentMonth {
                    return .outMonthDay(day)
                }
                
                return .day(day)
            }
            newSnapshot.appendItems(items , toSection: section)
        }
        monthYearPickerView.setDateRange(startDate: months.first!.firstDay, endDate: .now)
        diffableDataSource.apply(newSnapshot, animatingDifferences: false) { [self] in
            if atFirstShowOfCalendarView {
                atFirstShowOfCalendarView = false
                guard let lastMonth = months.last else { return }
                scroll(to: lastMonth)
            }
        }
    }
    
    private func makeCollectionView() -> UICollectionView {
        
        let layout = makeCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.allowsSelection = true
        
        collectionView.register(
            DayCell.self,
            forCellWithReuseIdentifier: DayCell.identifier
        )
        
        collectionView.register(
            EmptyCell.self,
            forCellWithReuseIdentifier: EmptyCell.identifier
        )
        
        return collectionView
    }
    
    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
         
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: {
                [weak self] sectionIndex,
                environment in
                
                guard let self,
                      sectionIndex < self.viewModel.months.count else { return CalendarCompositionalLayout.emptySection() }
                
                let month = self.viewModel.months[sectionIndex]
                
                return CalendarCompositionalLayout.make(
                    config: self.viewModel.config,
                    calendarWidth: environment.container.contentSize.width,
                    calendarHeight: environment.container.contentSize.height,
                    for: month
                )
            }
        )
        
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .horizontal
        layoutConfig.interSectionSpacing = 0
        layout.configuration = layoutConfig
        
        return layout
    }
    
    func scroll(to month: CalendarMonth, animated: Bool = false) {
        guard let index = viewModel.months.firstIndex(of: month) else { return }
        
        guard index < collectionView.numberOfSections else {
            print("Invalid Index in month")
            return
        }
        
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        
        let monthYearString = month.firstDay.transformDateToMonthAndYear()
        monthYearButton.setMonthYearTitle(monthYear: monthYearString)
    }
    
    func scrollToToday(animated: Bool = true) {
        let today = Date()
        if let month = viewModel.months.first(where: { $0.firstDay.year == today.year && $0.firstDay.month == today.month }) {
            scroll(to: month, animated: animated)
        }
    }
    
    private func getCurrentVisibleSection() -> Int {
        
        let snapshot = diffableDataSource.snapshot()
        let numberOfSections = snapshot.numberOfSections
        let pageWidth = collectionView.bounds.width
        let currentPage = Int(round(collectionView.contentOffset.x / pageWidth))
        
        guard currentPage >= 0 && currentPage < numberOfSections else {
                return 0
        }
        
        return currentPage
    }
}

extension CalendarView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .day(let day):
            viewModel.selectedDate = day.date
            viewModel.selectedDay = day
            var snapshot = diffableDataSource.snapshot()
            snapshot.reconfigureItems([item])
            diffableDataSource.apply(snapshot)
            delegate?.calendarView(self, didSelect: day)
        case .outMonthDay(_):
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .day:
            viewModel.selectedDate = nil
            viewModel.selectedDay = nil
            
            var snapshot = diffableDataSource.snapshot()
            snapshot.reconfigureItems([item])
            diffableDataSource.apply(snapshot)
        case .outMonthDay(_):
            break
        }
    }
    
}

extension CalendarView {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("this is my next month indexpath: \(indexPath)")
        delegate?.calendarView(self, willDisplay: cell, forItemAt: indexPath)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let currentIndex = Int(round(scrollView.contentOffset.x / pageWidth))
        let numberOfSections = diffableDataSource.snapshot().numberOfSections
        guard let section = diffableDataSource.sectionIdentifier(for: currentIndex) else { return }
        guard currentIndex < numberOfSections else { return }
        switch section {
        case .month(let month):
            let monthYearString = month.firstDay.transformDateToMonthAndYear()
            monthYearButton.setMonthYearTitle(monthYear: monthYearString)
            
            delegate?.calendarView(self, didChangeTo: month)
        }
    }
}

extension CalendarView: MonthYearPickerViewDelegate {
    
    func monthYearPickerView(_ picker: MonthYearPickerView, didSelect month: Int, year: Int) {
        var components = DateComponents(year: year, month: month)
        components.day = 1
        
        guard let date = Calendar.current.date(from: components) else { return }
        
        if let month = viewModel.months.first(where: { $0.firstDay.year == date.year && $0.firstDay.month == date.month }) {
            scroll(to: month, animated: false)
        }
    }
}

extension CalendarView {
    
    func bindDiffableDataSourceActions() {
        diffableDataSourceActionPassthroughSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self else { return }
                let dayDiary = item.dayDiary
                let actionType = item.type
                
                switch actionType {
                case .delete:
                    viewModel.delete(diary: dayDiary)
                case .update(let name, let handler):
                    viewModel.renameRecording(diary: dayDiary, name: name, handler: handler)
                case .add:
                    ()
                case .share(let handler):
                    guard let url = viewModel.shareRecording(dayDiary) else { return }
                    handler(url)
                }
            }
            .store(in: &cancellables)
    }
}

enum DatePickerAndCalendarState {
    case datePicker
    case calendar
}


enum DiffableDataSourceActionType {
    case delete
    case update(name: String, handler: () -> Void)
    case add
    case share(handler: (URL) -> Void)
}

struct DiffableDataSourceActionAndData {
    let dayDiary: RecordingFileDetails
    let type: DiffableDataSourceActionType
}
