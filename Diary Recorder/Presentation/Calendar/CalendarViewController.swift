//
//  CalendarViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 6/2/26.
//

import Foundation
import UIKit

class CalendarViewController: UIViewController {
        
    private let viewModel: CalendarViewModel
    
    private let calendarViewParentView = UIView()
    private let calendarView = UICalendarView()
    
    private let tableViewParentView = UIView()
    private let tableView = UITableView()
    
    private let todayButton = UIButton()
    
    
    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> CalendarViewController {
        let viewModel = CalendarViewModel()
        let viewController = CalendarViewController(viewModel: viewModel)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        setupUI()
        
    }
    
    private func setupUI() {
        navigationBarSetupUI()
        setupCalendarView()
    }
    
    private func setupCalendarView() {
        
        calendarViewParentView.backgroundColor = .systemBackground
        calendarViewParentView.layer.cornerRadius = 20
        
        view.addSubview(calendarViewParentView)
        
        calendarViewParentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 7
        calendarView.calendar = calendar
        calendarView.locale = Locale(identifier: "en_US")
        calendarView.delegate = self
        calendarView.fontDesign = .rounded
        calendarView.tintColor = .orange
        calendarView.backgroundColor = .systemBackground
        calendarView.layer.cornerRadius = 20
        
        
        
//        calendarView.translatesAutoresizingMaskIntoConstraints = false
//        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
//        dateSelection.selectedDate =
        calendarView.selectionBehavior = dateSelection
        
        calendarViewParentView.addSubview(calendarView)
        
        //calendarView.reloadDecorations(forDateComponents: [], animated: true)
        
        
        calendarView.snp.makeConstraints { make in

            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
            //make.height.equalTo(300)

        }
        
        todayButton.configuration = .plain()
        todayButton.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
        todayButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.showToday()
        }, for: .touchUpInside)
        
        tableViewParentView.addSubview(todayButton)
        todayButton.snp.makeConstraints { make in
            //make.size.equalTo(50)
            make.center.equalToSuperview()
        }
        
        tableViewParentView.backgroundColor = .orange
        tableViewParentView.layer.cornerRadius = 20
        view.addSubview(tableViewParentView)
        
        tableViewParentView.snp.makeConstraints { make in
            make.top.equalTo(calendarViewParentView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(calendarViewParentView)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func navigationBarSetupUI() {
        navigationItem.title = "Diary List"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.roundedFont(ofSize: 20, weight: .semibold)
        ]
        //appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.init(named: "MainColor")
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
}

extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("datecomponent is: \(dateComponents)")
    }
    
    func showToday() {
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        calendarView.setVisibleDateComponents(Calendar.current.dateComponents([.year, .month], from: Date()), animated: true)
        
        let singleSelection = UICalendarSelectionSingleDate(delegate: self)
        singleSelection.selectedDate = today
        calendarView.selectionBehavior = singleSelection
    }
    
    
    func calendarView(_ calendarView: UICalendarView,
                         decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        
            
//            let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//            
//            // اگر روز فعلی بود
//            if dateComponents == today {
//                return UICalendarView.Decoration.default(
//                    color: .systemBlue,        // رنگ دلخواه برای امروز (مثلاً نارنجی)
//                    size: .small                 // .small / .medium / .large
//                )
//            }
//            
//            // برای روزهای دیگر decoration نده (یا decoration دلخواه خودت)
//            return nil
        
        return .default(color: .green, size: .small)
        }
    
    
}
