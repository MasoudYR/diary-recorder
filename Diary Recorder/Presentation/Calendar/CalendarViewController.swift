//
//  CalendarViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit
import Combine
import SnapKit

class CalendarViewController: UIViewController, CalendarViewDelegate, CalendarViewDataSource {
    
    private let viewModel: CalendarViewModel
    private let router: CalendarRouter
    
    private let parentDiariesListTableView = UIView()
    private let diariesListTableView = UITableView()
    private var calendarView: CalendarView!
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(viewModel: CalendarViewModel, router: CalendarRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.calendarViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> CalendarViewController {
        let viewModel =  CalendarViewModel()
        let router = CalendarRouter()
        let viewController = CalendarViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main
        navigationBarSetupUI()
        bindViewModel()
        setupCalendar()
        setupCalendarViewLayout()
        setupDiariesListTableView()
    }
    
    private func navigationBarSetupUI() {
        navigationItem.title = "Diaries Calendar"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.roundedFont(ofSize: 23, weight: .regular)
        ]
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.init(named: "MainColor")
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
    
    private func setupCalendar() {
        let startDate = viewModel.getOldestDiaryDate()
        
        let config = CalendarConfig(
            startDate: startDate ,
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
            selectedBackgroundColor: .systemGray,
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
            make.horizontalEdges.equalToSuperview().inset(15)
            make.height.equalTo(400)
        }
    }
    
    private func setupDiariesListTableView() {
        parentDiariesListTableView.backgroundColor = .systemBackground
        parentDiariesListTableView.layer.cornerRadius = 20
        parentDiariesListTableView.layer.masksToBounds = true
        
        view.addSubview(parentDiariesListTableView)
        
        parentDiariesListTableView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(10)
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
        
        viewModel.renameCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                guard let self,
                      let selectedDiary = viewModel.selectedDiary else { return }

                let actionType = DiffableDataSourceActionType.update(name: name, handler: { [weak self] in
                    guard let self else { return }
                    self.viewModel.getOneDayDiareiesList(date: selectedDiary.date)
                }
                )
                let diffableDataSourceActionAndData = DiffableDataSourceActionAndData(dayDiary: selectedDiary, type: actionType)
                
                calendarView.diffableDataSourceActionPassthroughSubject.send(diffableDataSourceActionAndData)
                
            }
            .store(in: &cancellables)
    }
}

extension CalendarViewController {
    
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

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let diaryIndex = indexPath.row
        let diariesDataList = viewModel.dayDiariesList
        router.navigateToDiaryPlayer(
            diaryIndex: diaryIndex,
            diaryListDataCollection: diariesDataList
        )
        diariesListTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CalendarViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            self.router.navigateToDeleteAlert(
                deleteHandler: { [weak self] in
                    guard let self else { return }
                    let dayDiary = viewModel.dayDiariesList.remove(at: indexPath.row)
                    diariesListTableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    
                    let actionType = DiffableDataSourceActionType.delete
                    let diffableDataSourceActionAndData = DiffableDataSourceActionAndData(dayDiary: dayDiary, type: actionType)
                    calendarView.diffableDataSourceActionPassthroughSubject.send(diffableDataSourceActionAndData)
                }
            )
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, completion in
            guard let self else { return }
            let dayDiary = viewModel.dayDiariesList[indexPath.row]
            
            viewModel.selectedDiary = dayDiary
            
            self.router.navigateToRenameDiary(selectedDiary: dayDiary, nameCurrentValueSubject: viewModel.renameCurrentValueSubject)
            
            completion(true)
        }
        
        renameAction.image = UIImage(systemName: "pencil")
        renameAction.backgroundColor = .systemGreen
        
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
            guard let self else { return }
            let dayDiary = viewModel.dayDiariesList[indexPath.row]
            
            let actionType = DiffableDataSourceActionType.share(handler: { [weak self] url in
                guard let self else { return }
                router.navigateToShareActivityViewController(fileURL: url)
            }
            )
            let diffableDataSourceActionAndData = DiffableDataSourceActionAndData(dayDiary: dayDiary, type: actionType)
            calendarView.diffableDataSourceActionPassthroughSubject.send(diffableDataSourceActionAndData)
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let configuration = UISwipeActionsConfiguration(
            actions: [
                deleteAction,
                renameAction,
                shareAction
            ]
        )
        return configuration
    }
}
