//
//  DiaryCustomizerViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import Combine

class DiaryCustomizerViewController: UIViewController {
    
    private let viewModel: DiaryCustomizerViewModel
    private let router: DiaryCustomizerRouter
    
    private let vStackView = UIStackView()
    private let emojiHCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: DiaryCustomizerViewModel, router: DiaryCustomizerRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.viewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupUI()
    }
    
    static func make() -> DiaryCustomizerViewController {
        let viewModel = DiaryCustomizerViewModel()
        let router = DiaryCustomizerRouter()
        let viewController = DiaryCustomizerViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    private func setupUI() {
        setupVStackView()
        setupEmojiHCollectionView()
        bindingViewModel()
    }
    
    private func setupVStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 10
        vStackView.distribution = .fill
        vStackView.alignment = .fill
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        view.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupEmojiHCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        emojiHCollectionView.collectionViewLayout = layout
        emojiHCollectionView.backgroundColor = .clear
        emojiHCollectionView.showsHorizontalScrollIndicator = false
        emojiHCollectionView.delegate = self
        emojiHCollectionView.dataSource = self
        emojiHCollectionView.register(EmojiHCollectionCell.self, forCellWithReuseIdentifier: EmojiHCollectionCell.identifier)
        
        vStackView.addArrangedSubview(emojiHCollectionView)
        
        emojiHCollectionView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func bindingViewModel(){
        viewModel.$selectedEmoji
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPath in
                guard let self else { return }
                emojiHCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension DiaryCustomizerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.emojiArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiHCollectionCell.identifier, for: indexPath) as! EmojiHCollectionCell
        if indexPath == viewModel.selectedEmoji {
            cell.configue(image: viewModel.emojiArray[indexPath.row].colorImage)
        } else {
            cell.configue(image: viewModel.emojiArray[indexPath.row].grayscaleImage)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item: \(viewModel.emojiArray[indexPath.row])")
        viewModel.selectedEmoji = indexPath
    }
}
