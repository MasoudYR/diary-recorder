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
    
    func navigateToDiaryPlayer(){
        guard let diaryListViewController else { return }
        let diaryPlayerViewController = DiaryPlayerViewController.make()
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
}
