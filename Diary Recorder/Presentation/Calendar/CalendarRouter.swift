//
//  CalendarRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 6/22/26.
//

import Foundation
import Combine
import UIKit

class CalendarRouter {
    weak var calendarViewController: CalendarViewController?
    
    init() {
        
    }
    
    func navigateToDeleteAlert(deleteHandler: @escaping () -> Void) {
        guard let calendarViewController else { return }
        let deleteAlertViewController = DeleteAlertViewController.make(
            title: "Delete Alert",
            message: "Are you sure you want to delete this file?",
            deleteHandler: deleteHandler
        )
        calendarViewController.present(deleteAlertViewController, animated: true)
    }
    
    func navigateToAlert(title: String, message: String) {
        guard let calendarViewController else { return }
        let alertViewController = AlertViewController.make()
        alertViewController.config(title: title, message: message)
        calendarViewController.present(alertViewController, animated: true)
    }
    
    func navigateToRenameDiary(selectedDiary: RecordingFileDetails, nameCurrentValueSubject: PassthroughSubject<String, Never>) {
        guard let calendarViewController else { return }
        print("we have to show name diary")
        let nameDiaryViewController = NameDiaryViewController.make(lastSavedDiary: selectedDiary, nameCurrentValueSubject: nameCurrentValueSubject)
        
        if let sheet  = nameDiaryViewController.sheetPresentationController {
            sheet.detents = [
                .custom { context in
                    return 200
                }
            ]
            
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 20
        }
        nameDiaryViewController.isModalInPresentation = true
        calendarViewController.present(nameDiaryViewController, animated: true)
    }
    
    func navigateToShareActivityViewController(fileURL: URL?){
        guard let calendarViewController else { return }
        guard let fileURL else { return }
        let activityItems: [URL] = [fileURL]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        calendarViewController.present(activityViewController, animated: true)
    }
    
    func navigateToDiaryPlayer(diaryIndex: Int, diaryListDataCollection: [RecordingFileDetails]){
        guard let calendarViewController else { return }
        let diaryPlayerViewController = DiaryPlayerViewController.make(diaryIndex: diaryIndex, diaryListDataCollection: diaryListDataCollection)
        if let sheet = diaryPlayerViewController.sheetPresentationController {
            sheet.detents = [
                .custom { context in
                    return 300
                }
            ]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 20
        }
        calendarViewController.present(diaryPlayerViewController, animated: true)
    }
}
