//
//  CalendarViewDataSource.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

protocol CalendarViewDataSource: AnyObject {
    func calendarView(
        _ calendarView: CalendarView,
        cellFor day: CalendarDay,
        isSelected: Bool,
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell?

    func calendarView(_ cv: CalendarView, detailViewFor day: CalendarDay) -> UIView?
}
extension CalendarViewDataSource {
    func calendarView(
        _ cv: CalendarView,
        cellFor day: CalendarDay,
        isSelected: Bool,
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionViewCell? { nil }
    
    func calendarView(_ cv: CalendarView, detailViewFor day: CalendarDay) -> UIView? { nil }
}
