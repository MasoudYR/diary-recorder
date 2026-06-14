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
    
    private(set) var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<CalendarSection, CalendarItem>!
    
    // panel جزئیات روز انتخاب‌شده
    private let detailPanel = UIView()
    private var detailPanelHeight: NSLayoutConstraint!
    private var currentDetailView: UIView?
    /// ino badan eslahesh kon...
    
    private var collectionHeightConstraint: Constraint!
    private var lastLayoutSize: CGSize = .zero
    
    private var cancellables = Set<AnyCancellable>()
    
    init(config: CalendarConfig = .default) {
        self.viewModel = Calendar3ViewModel(config: config)
        super.init(frame: .zero)
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
        if bounds.width > 0, bounds.height > 0, bounds.size != lastLayoutSize {
            lastLayoutSize = bounds.size
            refreshLayout()
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
        
        collectionView.register(
            WeekDayTitlesRowHeader.self,
            forSupplementaryViewOfKind: WeekDayTitlesRowHeader.kind,
            withReuseIdentifier: WeekDayTitlesRowHeader.identifier
        )
        
        addSubview(collectionView)
        
//        let calendarViewHeight = CalendarCompositionalLayout.totalHeight(config: viewModel.config)
//        collectionView.snp.makeConstraints { make in
//            self.collectionHeightConstraint = make.height.equalTo(calendarViewHeight).constraint
//            make.edges.equalToSuperview()
//        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
                    outOfMonthAlpha: config.outOfMonthDaysAlpha,
                    badgeNum: nil
                )
                return cell
                
            case .outMonthDay(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCell.identifier, for: indexPath) as! EmptyCell
                return cell
            }
        }
        
        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            
            if kind == WeekDayTitlesRowHeader.kind {
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: WeekDayTitlesRowHeader.identifier,
                    for: indexPath
                ) as! WeekDayTitlesRowHeader
                
                return view
            }
            return nil
        }
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
                
                self.collectionView.visibleCells.forEach { cell in
                    guard let indexPath = self.collectionView.indexPath(for: cell),
                          let item = self.diffableDataSource.itemIdentifier(for: indexPath) else { return }
                    switch item {
                    case .day(let day):
                        let dayCell = cell as! DayCell
                        let isSelected = self.viewModel.isSelected(day)
                        dayCell.configure(
                            day: day,
                            isToday: day.isToday,
                            isSelected: isSelected,
                            isOutOfMonth: !day.isCurrentMonth,
                            outOfMonthAlpha: self.viewModel.config.outOfMonthDaysAlpha,
                            badgeNum: nil
                        )
                    case .outMonthDay(_):
                        break
                    }
                }
            }
            .store(in: &cancellables)
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
        guard bounds.width > 0, bounds.height > 0 else { return }
        print(">>> Refresh layout is  work")
        print("this is boundsWidth: \(bounds.width), and this is boundsHeight: \(bounds.height)")
        let newLayout = CalendarCompositionalLayout.make(config: viewModel.config, calendarWidth: bounds.width, calendarHeight: bounds.height)
        //let newLayout = CalendarCompositionalLayout.make(config: viewModel.config, pageWidth: bounds.width)
        collectionView.setCollectionViewLayout(newLayout, animated: false)
        
        //let newHeight = CalendarCompositionalLayout.totalHeight(config: viewModel.config)
//        collectionView.snp.makeConstraints { make in
//            self.collectionHeightConstraint = make.height.equalTo(400).constraint
//        }

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
    
    // به روزرسانی اندازه ها
    func updateSize(
        sectionInset: NSDirectionalEdgeInsets?,
        cellHeight: CGFloat?,
        cellInRowSpacing: CGFloat?,
        rowsSpacing: CGFloat?,
        weekDayTitlesRowHeight: CGFloat?
    ) {
        if let sectionInset { config.sectionInset = sectionInset }
        //if let cellHeight { config.cellHeight = cellHeight }
        if let cellInRowSpacing { config.cellInRowSpacing = cellInRowSpacing }
        if let rowsSpacing { config.rowsSpacing = rowsSpacing }
        if let weekDayTitlesRowHeight { config.weekDayTitlesRowHeight = weekDayTitlesRowHeight }
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
        case .outMonthDay(_):
            break
        }
    }
    
    //تشخیص ماه بعد از اسکرول شدن. یا تغییر کردن!!!
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyCurrentMonth()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        notifyCurrentMonth()
    }
    
    private func notifyCurrentMonth() {
        let cx = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let cy = collectionView.bounds.height / 2
        guard let indexPath = collectionView.indexPathForItem(at: CGPoint(x: cx, y: cy)),
              indexPath.section < viewModel.months.count else { return }
        let month = viewModel.months[indexPath.section]
        //viewModel.config  // just access
        delegate?.calendarView(self, didChangeTo: month)
    }
  
}
