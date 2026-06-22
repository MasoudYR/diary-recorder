//
//  Calendar3ViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit
import Combine
import SnapKit

class Calendar3ViewController: UIViewController, CalendarViewDelegate, CalendarViewDataSource {
    
    private let viewModel: Calendar3ViewModel
    private let parentDiariesListTableView = UIView()
    private let diariesListTableView = UITableView()
    private var calendarView: CalendarView!
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(viewModel: Calendar3ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> Calendar3ViewController {
        let viewModel =  Calendar3ViewModel()
        let viewController = Calendar3ViewController(viewModel: viewModel)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main
        bindViewModel()
        setupCalendar()
        setupCalendarViewLayout()
        setupDiariesListTableView()
    }
    
    private func setupCalendar() {
        var dateComponents = DateComponents()
        dateComponents.year = 1970
        dateComponents.month = 1
        dateComponents.day = 1
        let date19700101 = Calendar.current.date(from: dateComponents)!
        
        let config = CalendarConfig(
            startDate: date19700101 ,
            endDate: Date(),
            firstWeekday: 7,
            cellInRowSpacing: 2,
            rowsSpacing: 2,
            weekDayTitlesRowHeight: 30,
            sectionInset: .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        )
        
        DayCell.appearance = DayAppearance(
            normalFont: .roundedFont(ofSize: 18, weight: .semibold),
            normalColor: .label,
            normalBackgroundColor: .main,
            normalBadgeNum: 0,
            todayFont: .roundedFont(ofSize: 18, weight: .semibold),
            todayColor: .systemRed,
            todayBackgroundColor: .main,
            todayBadgeNum: 0,
            selectedFont: .roundedFont(ofSize: 18, weight: .semibold),
            selectedColor: .label,
            selectedBackgroundColor: .orange,
            selectedBadgeNum: 0,
            cornerRadius: 20,
            badgeFontSize: 12
        )
        
        WeekDayTitlesRowHeader.appearance = WeekDayTitlesAppearance(
            font: .roundedFont(ofSize: 20, weight: .bold),
            color: .darkGray,
            spaceBetweenWeekDays: 2
        )
        
        calendarView = CalendarView(config: config)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.backgroundColor = .systemBackground
        calendarView.layer.cornerRadius = 20
        calendarView.clipsToBounds = true
    }
    
    private func setupCalendarViewLayout() {
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
        }
    }
    
    private func setupDiariesListTableView() {
        parentDiariesListTableView.backgroundColor = .systemBackground
        parentDiariesListTableView.layer.cornerRadius = 20
        parentDiariesListTableView.layer.masksToBounds = true
        
        view.addSubview(parentDiariesListTableView)
        
        parentDiariesListTableView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(calendarView)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        parentDiariesListTableView.isHidden = true
        diariesListTableView.register(DiaryListTableViewCell.self, forCellReuseIdentifier: DiaryListTableViewCell.identifier)
        diariesListTableView.delegate = self
        diariesListTableView.dataSource = self
        diariesListTableView.rowHeight = 60
        diariesListTableView.showsVerticalScrollIndicator = false
        diariesListTableView.separatorInset = .zero
        diariesListTableView.bounces = false
        diariesListTableView.backgroundColor = .systemBackground
        
        parentDiariesListTableView.addSubview(diariesListTableView)
        
        diariesListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    private func bindViewModel() {
        viewModel.$dayDiariesList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                diariesListTableView.reloadData()
                parentDiariesListTableView.isHidden = viewModel.dayDiariesList.isEmpty
            }
            .store(in: &cancellables)
    }
}

extension Calendar3ViewController {
    
    func calendarView(_ cv: CalendarView, didSelect day: CalendarDay) {
        print("✅ انتخاب شد: \(day.date)")
        viewModel.getOneDayDiareiesList(date: day.date)
    }
    
    func calendarView(_ calendarView: CalendarView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("this is next indexPath: \(indexPath)")
    }
    
    func calendarView(_ cv: CalendarView, didChangeTo month: CalendarMonth) {
        //navigationItem..subtitle = month.title
    }
}

extension Calendar3ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dayDiariesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = diariesListTableView.dequeueReusableCell(withIdentifier: DiaryListTableViewCell.identifier) as! DiaryListTableViewCell
        
        let diary = viewModel.dayDiariesList[indexPath.row]
        let name = diary.name
        let duration = viewModel.transformTimeToString(diary.duration)
        let dateAndTime = viewModel.changeDateAndTime(diary.date)
        
        cell.configure(
            name: name,
            duration: duration,
            dateAndTime: dateAndTime
        )
        
        return cell
    }
    
    
}
