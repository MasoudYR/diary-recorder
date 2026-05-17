//
//  DiaryListRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation

class DiaryListRouter {
    weak var diaryListViewController: DiaryListViewController?
    
    init() {
        
    }
    
    func navigateToDiaryPlayer(diary: RecordingFileDetails){
        guard let diaryListViewController else { return }
        let diaryPlayerViewController = DiaryPlayerViewController.make(diary: diary)
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
}
