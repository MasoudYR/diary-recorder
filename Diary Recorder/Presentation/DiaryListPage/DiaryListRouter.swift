//
//  DiaryListRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import UIKit
import Combine

class DiaryListRouter {
    weak var diaryListViewController: DiaryListViewController?
    
    init() {
        
    }
    
    func navigateToDiaryPlayer(diaryIndex: Int, diaryListDataCollection: [RecordingFileDetails]){
        guard let diaryListViewController else { return }
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
            sheet.preferredCornerRadius = 16
        }
        diaryListViewController.present(diaryPlayerViewController, animated: true)
    }
    
    func navigateToDeleteAlert(deleteHandler: @escaping () -> Void){
        guard let diaryListViewController else { return }
        let deleteAlertViewController = DeleteAlertViewController.make(deleteHandler: deleteHandler)
        diaryListViewController.present(deleteAlertViewController, animated: true)
    }
    
    func navigateToShareActivityViewController(fileURL: URL?){
        guard let diaryListViewController else { return }
        guard let fileURL else { return }
        let activityItems: [URL] = [fileURL]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        diaryListViewController.present(activityViewController, animated: true)
    }
    
    func navigateToRenameDiary(selectedDiary: RecordingFileDetails, nameCurrentValueSubject: PassthroughSubject<String, Never>) {
        guard let diaryListViewController else { return }
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
            sheet.preferredCornerRadius = 16
        }
        nameDiaryViewController.isModalInPresentation = true
        diaryListViewController.present(nameDiaryViewController, animated: true)
    }
}
