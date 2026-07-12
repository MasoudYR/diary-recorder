//
//  DiaryCustomizerRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation

class DiaryCustomizerRouter {
    weak var diaryCustomizerViewController: DiaryCustomizerViewController?
    
    init() {
        
    }
    
    func navigateToEditPhoto() {
        guard let diaryCustomizerViewController else { return }
        let viewController = EditPhotoViewController.make()
        if let sheet  = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in return 250 }]
            
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.preferredCornerRadius = 20
        }
        //diaryCustomizerViewController.isModalInPresentation = true
        diaryCustomizerViewController.present(viewController, animated: true)
    }
}
