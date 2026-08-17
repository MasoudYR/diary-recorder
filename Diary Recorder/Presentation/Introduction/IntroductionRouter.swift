//
//  IntroductionRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 8/17/26.
//

import Foundation

class IntroductionRouter {
    
    weak var introductionViewController: IntroductionViewController?
    
    init() {
        
    }
    
    func navigateToNeedPassword() {
        guard let introductionViewController,
              let navigationController = introductionViewController.navigationController else { return }
        let needPasswordViewController = NeedPasswordViewController.make()
        navigationController.pushViewController(needPasswordViewController, animated: true)
    }
}
