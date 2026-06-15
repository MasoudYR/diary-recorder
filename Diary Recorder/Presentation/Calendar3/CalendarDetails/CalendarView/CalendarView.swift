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
    
    let viewModel: Calendar3ViewModel
    
    var config: CalendarConfig {
        get {viewModel.config}
        set {viewModel.config = newValue}
    }
    
    private let weekDayHeaderView = WeekDayTitlesRowHeader()
    
    private(set) var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<CalendarSection, CalendarItem>!
    
    // panel جزئیات روز انتخاب‌شده
    private let detailPanel = UIView()
    private var detailPanelHeight: NSLayoutConstraint!
    private var currentDetailView: UIView?
    /// ino badan eslahesh kon...
    
    private var lastLayoutSize: CGSize = .zero
    private var currentCellSize: CGSize = .zero
    
//    ina 2 taro pak nakon baraye badan bedard mikhore...
//    private var lastContentOffsetX: CGFloat = 0.0
//    private var hasTriggeredScroll: ScrollState = .noMove
    
   // private var collectionHeightConstraint: Constraint!
    private var cancellables = Set<AnyCancellable>()
    
    init(config: CalendarConfig = .default) {
        self.viewModel = Calendar3ViewModel(config: config)
        super.init(frame: .zero)
        setupWeekDayHeader()
        setupCollectionView()
        //buildDetailPanel()
        buildDiffableDataSource()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if !(collectionView.collectionViewLayout is UICollectionViewCompositionalLayout) {
//            print(">>> layout subviews condition is work")
//            refreshLayout()
//        }
//        
        if collectionView.bounds.width > 0, collectionView.bounds.height > 0, bounds.size != lastLayoutSize {
            lastLayoutSize = collectionView.bounds.size
            refreshLayout()
        }
    }
    
    private func setupWeekDayHeader() {
        addSubview(weekDayHeaderView)
        weekDayHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(config.sectionInset.leading)
            make.trailing.equalToSuperview().inset(config.sectionInset.trailing)
            make.height.equalTo(config.weekDayTitlesRowHeight)
        }
    }
    
    private func setupCollectionView() {
        let placeholder = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: placeholder)
        collectionView.backgroundColor = .systemMint
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        
        collectionView.register(
            DayCell.self,
            forCellWithReuseIdentifier: DayCell.identifier
        )
        
        collectionView.register(
            EmptyCell.self,
            forCellWithReuseIdentifier: EmptyCell.identifier
        )
        
        addSubview(collectionView)
        
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(weekDayHeaderView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func buildDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<CalendarSection, CalendarItem>(collectionView: collectionView) { [weak self]
            collectionView, indexPath, item in
            guard let self else { return EmptyCell() }
            
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
                    badgeNum: nil
                )
                return cell
                
            case .outMonthDay(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.identifier, for: indexPath) as! EmptyCell
                return cell
            }
        }
        
//        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
//            guard let self else { return nil }
//            
//            if kind == WeekDayTitlesRowHeader.kind {
//                let view = collectionView.dequeueReusableSupplementaryView(
//                    ofKind: kind,
//                    withReuseIdentifier: WeekDayTitlesRowHeader.identifier,
//                    for: indexPath
//                ) as! WeekDayTitlesRowHeader
//                
//                return view
//            }
//            return nil
//        }
    }
    
    private func bindViewModel() {
        viewModel.$months
            .receive(on: DispatchQueue.main)
            .sink { [weak self] months in
                guard let self else { return }
                self.applySnapshot(months: months)
                self.refreshLayout()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                reconfigureVisibleDayCell()
            }
            .store(in: &cancellables)
    }
    
    private func reconfigureVisibleDayCell() {
        collectionView.visibleCells.forEach { cell in
            guard let indexPath = collectionView.indexPath(for: cell),
                  let item = self.diffableDataSource.itemIdentifier(for: indexPath)  else { return }
            switch item {
            case .day(let day):
                guard let dayCell = cell as? DayCell else { return }
                
                let isSelected = self.viewModel.isSelected(day)
                dayCell.configure(
                    day: day,
                    isToday: day.isToday,
                    isSelected: isSelected,
                    isOutOfMonth: !day.isCurrentMonth,
                    badgeNum: 8
                )
            case .outMonthDay(_):
                break
                
            }
        }
    }
    
    private func applySnapshot(months: [CalendarMonth]) {
        var snapshot = NSDiffableDataSourceSnapshot<CalendarSection, CalendarItem>()
        for month in months {
            let section = CalendarSection.month(month)
            snapshot.appendSections([section])
            
            let items: [CalendarItem] = month.days.map { day in
                
                if !day.isCurrentMonth {
                    return .outMonthDay(day)
                }
                
                return .day(day)
            }
            snapshot.appendItems(items , toSection: section)
        }
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func refreshLayout() {
        guard collectionView.bounds.width > 0,
              collectionView.bounds.height > 0 else { return }
        
        print(">>> Refresh layout is  work")
        print("this is boundsWidth: \(bounds.width), and this is boundsHeight: \(bounds.height)")
        
//        let newLayout = CalendarCompositionalLayout.make(
//            config: viewModel.config,
//            calendarWidth: collectionView.bounds.width,
//            calendarHeight: collectionView.bounds.height,
//            for: <#CalendarMonth#>
//        )
        
//        collectionView.setCollectionViewLayout(newLayout, animated: false)
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: {
                [weak self] sectionIndex,
                environment in
                guard let self,
                      sectionIndex < self.viewModel.months.count else { return CalendarCompositionalLayout.emptySection() }
                
                let month = self.viewModel.months[sectionIndex]
                
                return CalendarCompositionalLayout.make(
                    config: self.viewModel.config,
                    calendarWidth: self.collectionView.bounds.width,
                    calendarHeight: self.collectionView.bounds.height,
                    for: month
                )
            }
        )
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .horizontal
        layoutConfig.interSectionSpacing = 0
        layout.configuration = layoutConfig
        
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    // اسکرول به یک ماه خاص
    func scroll(to month: CalendarMonth, animated: Bool = true) {
        guard let index = viewModel.months.firstIndex(of: month) else { return }
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    //اسکرول به امروز
    func scrollToToday(animated: Bool = true) {
        let today = Date()
        if let month = viewModel.months.first(where: { $0.firstDay.year == today.year && $0.firstDay.month == today.month }) {
            scroll(to: month, animated: animated)
        }
    }
    
    //inam badab dorostesh kon
    private func buildDetailPanel() {
        detailPanel.clipsToBounds = true
        addSubview(detailPanel)

        detailPanelHeight = detailPanel.heightAnchor.constraint(equalToConstant: 0)
        detailPanel.snp.makeConstraints { make in
            make.top.equalTo(collectionView)
            make.horizontalEdges.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
    }
    /// اینو بعدا درستش کن لطفا
    private func showDetail(for day: CalendarDay) {
        currentDetailView?.removeFromSuperview()

        let view = dataSource?.calendarView(self, detailViewFor: day)
                    ?? makeDefaultDetailView(day: day)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        detailPanel.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: detailPanel.topAnchor),
            view.leadingAnchor.constraint(equalTo: detailPanel.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: detailPanel.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: detailPanel.bottomAnchor),
        ])
        currentDetailView = view

        //
    }
    
    // این یکی هم همینطور
    private func makeDefaultDetailView(day: CalendarDay) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 14
        container.layer.cornerCurve  = .continuous

        let fmt = DateFormatter(); fmt.dateStyle = .full
        let label = UILabel()
        label.text          = fmt.string(from: day.date)
        label.font          = .systemFont(ofSize: 15, weight: .medium)
        label.textColor     = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        return container
    }
    
    
}

extension CalendarView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .day(let day):
            delegate?.calendarView(self, didSelect: day)
            showDetail(for: day)
            viewModel.selectedDate = day.date
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
        
        print("سکشن فعلی: \(currentIndex)")
        
        guard currentIndex < viewModel.months.count else { return }
        
        let currentMonth = viewModel.months[currentIndex]
        delegate?.calendarView(self, didChangeTo: currentMonth)
    }
}


extension CalendarView {
//    inaro pak nakon baraye scroll badab be dard mikhore...
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//       lastContentOffsetX = scrollView.contentOffset.x
//        hasTriggeredScroll = .noMove
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentOffsetX = scrollView.contentOffset.x
//        
//        guard currentOffsetX != lastContentOffsetX else { return }
//        
//        if currentOffsetX > lastContentOffsetX + 8, hasTriggeredScroll != .right {
//                hasTriggeredScroll = .right
//                didStartScrollToNextMonth()
//        } else if currentOffsetX < lastContentOffsetX - 8, hasTriggeredScroll != .left {
//                hasTriggeredScroll = .left
//            didStartScrollToPreviousMonth()
//        }
//        
//    }
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            resetScrollState()
//        }
//    }
//    
//    private func didStartScrollToNextMonth() {
//        print("اسکرول به راست شروع شد - دریافت دیتای ماه بعد")
//    }
//    
//    private func didStartScrollToPreviousMonth() {
//        print("اسکرول به چپ شروع شد - دریافت دیتای ماه قبل")
//    }
//    
//    private func resetScrollState() {
//        hasTriggeredScroll = .noMove
//        lastContentOffsetX = 0.0
//    }
}

enum ScrollState {
    case noMove
    case right
    case left
}
