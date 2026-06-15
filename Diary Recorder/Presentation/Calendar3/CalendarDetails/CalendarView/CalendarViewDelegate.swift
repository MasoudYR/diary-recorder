//
//  CalendarViewDelegate.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

protocol CalendarViewDelegate: AnyObject {
    
    func calendarView(_ calendarView: CalendarView, didSelect day: CalendarDay)
    
    func calendarView(_ calendarView: CalendarView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    func calendarView(_ calendarView: CalendarView, didChangeTo: CalendarMonth)
}

extension CalendarViewDelegate {
    func calendarView(_ cv: CalendarView, didDeselect day: CalendarDay) {}
}
