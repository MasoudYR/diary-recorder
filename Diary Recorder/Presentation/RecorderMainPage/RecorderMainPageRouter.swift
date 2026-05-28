//
//  RecorderMainPageRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 5/9/26.
//

import Foundation
import Combine

class RecorderMainPageRouter {
    weak var recorderMainPageViewController: RecorderMainPageViewController?
    
    init() {
        
    }
    
    func navigateToDiaryList() {
        guard let recorderMainPageViewController,
              let navigationController = recorderMainPageViewController.navigationController else { return }
        let diaryListViewController = DiaryListViewController.make()
        navigationController.pushViewController(diaryListViewController, animated: true)
    }
    
    func navigateToNameDiary(lastSavedDiary: RecordingFileDetails, nameCurrentValueSubject: PassthroughSubject<String, Never>) {
        guard let recorderMainPageViewController else { return }
        print("we have to show name diary")
        let nameDiaryViewController = NameDiaryViewController.make(lastSavedDiary: lastSavedDiary, nameCurrentValueSubject: nameCurrentValueSubject)
        
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
        recorderMainPageViewController.present(nameDiaryViewController, animated: true)
    }
}
