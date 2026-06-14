//
//  CalendarCompositionalLayout.swift
//  Diary Recorder
//
//  Created by Masoud on 6/10/26.
//

import Foundation
import UIKit

enum CalendarCompositionalLayout {
    
    static func cellSize(
        config: CalendarConfig,
        calendarWidth: CGFloat,
        calendarHeight: CGFloat,
        numberOfWeeks: Int = 6
    ) -> CGSize {
        let inset = config.sectionInset
        let vSpace = config.cellInRowSpacing
        let hSpace = config.rowsSpacing
        //let headerHeight = config.weekDayTitlesRowHeight
        
        let usableWidth  = calendarWidth - inset.leading - inset.trailing
        let usableHeight = calendarHeight - inset.top - inset.bottom

        let cellWidth  = (usableWidth  - hSpace * 6) / 7
        let cellHeight = (usableHeight - vSpace * CGFloat(numberOfWeeks - 1)) / CGFloat(numberOfWeeks)

        return CGSize(width: max(0, cellWidth), height: max(0, cellHeight))
    }
    
    static func make(
        config: CalendarConfig,
        calendarWidth: CGFloat,
        calendarHeight: CGFloat,
        numberOfWeeks: Int = 6
    ) -> UICollectionViewCompositionalLayout {
        
        let inset = config.sectionInset
        let vSpace = config.cellInRowSpacing
        let hSpace = config.rowsSpacing
        //let headerHeight = config.weekDayTitlesRowHeight
        
        let usableWidth = calendarWidth - inset.leading - inset.trailing
        let usableHeight = calendarHeight - inset.top - inset.bottom
        
        let cellSize = cellSize(
            config: config,
            calendarWidth: calendarWidth,
            calendarHeight: calendarHeight,
            numberOfWeeks: numberOfWeeks
        )
        
        let cellWidth = cellSize.width
        let cellHeight = cellSize.height
        let weekWidth = usableWidth
        let weekHeight = cellSize.height
        let monthWidth = usableWidth
        let monthHeight = usableHeight
        //let headerWidth = usableWidth
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(cellWidth),
            heightDimension: .absolute(cellHeight)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let rowWeekSize = NSCollectionLayoutSize(
            widthDimension: .absolute(weekWidth),
            heightDimension: .absolute(weekHeight)
        )
        
        let rowWeekGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: rowWeekSize,
            subitems: [item]
        )
        
        rowWeekGroup.interItemSpacing = .fixed(hSpace)
        
        let monthGroupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(monthWidth),
            heightDimension: .absolute(monthHeight)
        )
        
        let monthGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: monthGroupSize,
            subitems: [rowWeekGroup]
        )
        
        monthGroup.interItemSpacing = .fixed(vSpace)
        
        let section = NSCollectionLayoutSection(group: monthGroup)
        section.contentInsets = inset
        
//        let weekDayTitlesSize = NSCollectionLayoutSize(
//            widthDimension: .absolute(headerWidth),
//            heightDimension: .absolute(headerHeight)
//        )
//        
//        let weekDayTitlesHeader = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: weekDayTitlesSize,
//            elementKind: WeekDayTitlesRowHeader.kind,
//            alignment: .top
//        )
        
//        weekDayTitlesHeader.pinToVisibleBounds =  true
//        section.boundarySupplementaryItems = [weekDayTitlesHeader]
        //section.orthogonalScrollingBehavior = .groupPagingCentered
        
       // let layout = UICollectionViewCompositionalLayout(section: section)
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .horizontal
        layoutConfig.interSectionSpacing = 0
        
        
        return UICollectionViewCompositionalLayout(section: section, configuration: layoutConfig)
    }
    
//    static func totalHeight(config: CalendarConfig) -> CGFloat {
//        config.weekDayTitlesRowHeight
//        + config.cellHeight * 6
//        + config.rowsSpacing * 5
//        + config.sectionInset.top
//        + config.sectionInset.bottom
//    }
}
