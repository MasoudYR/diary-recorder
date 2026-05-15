//
//  DiaryListViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import UIKit
import Combine

class DiaryListViewController: UIViewController {
    
    private let viewModel: DiaryListViewModel
    private let router: DiaryListRouter
    
    private let diaryListTableView = UITableView()
    
    private var cancellables = Set<AnyCancellable>()

    
    init(viewModel: DiaryListViewModel, router: DiaryListRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.diaryListViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryListTableView.delegate = self
        diaryListTableView.dataSource = self
        diaryListTableView.register(DiaryListTableViewCell.self, forCellReuseIdentifier: DiaryListTableViewCell.identifier)
        navigationBarSetupUI()
        setupUI()
        bindViewModel()
    }
    
    static func make() -> DiaryListViewController {
        let viewModel = DiaryListViewModel()
        let router = DiaryListRouter()
        let viewController = DiaryListViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    private func navigationBarSetupUI() {
        navigationItem.title = "Diary List"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 18)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(diaryListTableView)
        diaryListTableView.backgroundColor = .gray
        diaryListTableView.bounces = false
        diaryListTableView.separatorInset = .zero
        diaryListTableView.showsVerticalScrollIndicator = false
        diaryListTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
    }
    
    private func bindViewModel() {
        viewModel.$diaryListDataCollection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.diaryListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension DiaryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.diaryListDataCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = diaryListTableView.dequeueReusableCell(withIdentifier: DiaryListTableViewCell.identifier) as! DiaryListTableViewCell
        let name = viewModel.diaryListDataCollection[indexPath.row].name
        let duration = viewModel.changeDuration(viewModel.diaryListDataCollection[indexPath.row].duration)
        let dateAndTime = viewModel.changeDateAndTime(viewModel.diaryListDataCollection[indexPath.row].date)
        cell.configure(
            name: name,
            duration: duration,
            dateAndTime: dateAndTime
        )
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        router.navigateToDiaryPlayer(diary: viewModel.diaryListDataCollection[indexPath.row])
        print(">>>>>, thie is file selected: \(viewModel.diaryListDataCollection[indexPath.row])")
    }
}
