//
//  RecorderMainPageRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 5/9/26.
//

import Foundation

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
}
