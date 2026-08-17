//
//  NeedPasswordViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 8/17/26.
//

import Foundation
import UIKit

class NeedPasswordViewController: UIViewController {
    
    private let viewModel: NeedPasswordViewModel
    private let router: NeedPasswordRouter
    
    init(viewModel: NeedPasswordViewModel, router: NeedPasswordRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> NeedPasswordViewController {
        let viewModel = NeedPasswordViewModel()
        let router = NeedPasswordRouter()
        let viewController = NeedPasswordViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}
