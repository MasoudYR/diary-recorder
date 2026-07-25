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
    
    private let diaryListTableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
            .font: UIFont.roundedFont(ofSize: 20, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.init(named: "MainColor")
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.init(named: "MainColor")
        
        diaryListTableView.backgroundColor = UIColor.init(named: "MainColor")
        diaryListTableView.bounces = false
        diaryListTableView.separatorInset = .zero
        diaryListTableView.showsVerticalScrollIndicator = false
        diaryListTableView.rowHeight = 60
        
        view.addSubview(diaryListTableView)
        
        diaryListTableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
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
        let diary = viewModel.diaryListDataCollection[indexPath.row]
        let name = diary.name
        let duration = viewModel.transformTimeToString(diary.duration)
        let recordTime = viewModel.changeDateAndTime(diary.date)
        let image = viewModel.getImageOfDiary(diary: diary)
        let emojiImage = viewModel.getEmojiOfDiary(diary: diary)
        
        cell.configure(
            diaryImage: image,
            name: name,
            recordTime: recordTime,
            duration: duration,
            emoji: emojiImage
        )
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let diaryIndex = indexPath.row
        let diaryListDataCollection = viewModel.diaryListDataCollection
        router.navigateToDiaryPlayer(
            diaryIndex: diaryIndex,
            diaryListDataCollection: diaryListDataCollection
        )
        print(">>>>>, thie is file selected: \(viewModel.diaryListDataCollection[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            self.router.navigateToDeleteAlert(
                deleteHandler: { [weak self] in
                    guard let self else { return }
                    self.viewModel.delete(
                        diary: viewModel.diaryListDataCollection[indexPath.row]
                    )
                }
            )
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
            guard let self else { return }
            let diary = viewModel.diaryListDataCollection[indexPath.row]
            guard let url = viewModel.share(diary: diary) else {
                completion(true)
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.router.navigateToShareActivityViewController(fileURL: url)
            }
            completion(true)
        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { [weak self] _, _, completion in
            guard let self else { return }
            let selectedDiary = viewModel.diaryListDataCollection[indexPath.row]
            viewModel.selectedDiary = selectedDiary
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.router.navigateToRenameDiary(selectedDiary: selectedDiary, nameCurrentValueSubject: viewModel.renameCurrentValueSubject)
            }
            completion(true)
        }
        renameAction.image = UIImage(systemName: "pencil")
        renameAction.backgroundColor = .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, renameAction, shareAction])
        return configuration
    }
}



