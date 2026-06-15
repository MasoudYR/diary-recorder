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
    
    private var calendarView: CalendarView!
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> Calendar3ViewController {
        let viewController = Calendar3ViewController()
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCalendar()
        setupLayout()
    }
    
    private func setupCalendar() {

        let config = CalendarConfig(
            startDate: Date().startOfMonth,
            endDate: Date().adding(months: 12).endOfMonth,
            firstWeekday: 7,
            cellInRowSpacing: 2,
            rowsSpacing: 2,
            weekDayTitlesRowHeight: 30,
            sectionInset: .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        )
        
        DayCell.appearance = DayAppearance(
            normalFont: .roundedFont(ofSize: 18, weight: .semibold),
            normalColor: .label,
            normalBackgroundColor: .systemBackground,
            normalBadgeNum: 0,
            todayFont: .roundedFont(ofSize: 18, weight: .semibold),
            todayColor: .systemRed,
            todayBackgroundColor: .systemBackground,
            todayBadgeNum: 0,
            selectedFont: .roundedFont(ofSize: 18, weight: .semibold),
            selectedColor: .label,
            selectedBackgroundColor: .orange,
            selectedBadgeNum: 0,
            cornerRadius: 20,
            badgeFontSize: 10
        )
        
        WeekDayTitlesRowHeader.appearance = WeekDayTitlesAppearance(
            font: .roundedFont(ofSize: 20, weight: .bold),
            color: .darkGray,
            spaceBetweenWeekDays: 2
        )
        
        calendarView = CalendarView(config: config)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.backgroundColor = .green
        calendarView.layer.cornerRadius = 20
    }
    
    private func setupLayout() {
        view.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(350)
        }
    }
}

extension Calendar3ViewController {
    
    func calendarView(_ cv: CalendarView, didSelect day: CalendarDay) {
        print("✅ انتخاب شد: \(day.date)")
    }
    
    func calendarView(_ calendarView: CalendarView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("this is next indexPath: \(indexPath)")
    }
    
    func calendarView(_ cv: CalendarView, didChangeTo month: CalendarMonth) {
        //navigationItem..subtitle = month.title
    }
}
