//
//  DiaryCustomizerViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import Combine
import AVFoundation
import PhotosUI
import TOCropViewController

class DiaryCustomizerViewController: UIViewController, PHPickerViewControllerDelegate {
    
    private let viewModel: DiaryCustomizerViewModel
    private let router: DiaryCustomizerRouter
    
    private let vStackView = UIStackView()
    private let parentImagePickerView = UIView()
    private let imagePickerButton = ImagePickerButton()
    private let emojiHCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let imagePicker = UIImagePickerController()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: DiaryCustomizerViewModel, router: DiaryCustomizerRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.diaryCustomizerViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main
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
        setupImagePickerButton()
        setupEmojiHCollectionView()
        bindingViewModel()
        actions()
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
    
    private func setupImagePickerButton() {
    
        imagePickerButton.configue(image: nil, photoState: .placeholder)
        
        parentImagePickerView.addSubview(imagePickerButton)
        
        imagePickerButton.snp.makeConstraints { make in
            make.size.equalTo(300)
            make.verticalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(parentImagePickerView)
    }
    
    private func setupEmojiHCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        emojiHCollectionView.collectionViewLayout = layout
        emojiHCollectionView.backgroundColor = .systemBackground
        emojiHCollectionView.showsHorizontalScrollIndicator = false
        emojiHCollectionView.layer.cornerRadius = 20
        emojiHCollectionView.layer.masksToBounds = true
        emojiHCollectionView.delegate = self
        emojiHCollectionView.dataSource = self
        emojiHCollectionView.register(EmojiHCollectionCell.self, forCellWithReuseIdentifier: EmojiHCollectionCell.identifier)
        
        vStackView.addArrangedSubview(emojiHCollectionView)
        
        emojiHCollectionView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    private func actions() {
        let imagePickerButtonActionId = UIAction.Identifier("imagePickerButtonActionId")
        let imagePickerButtonAction = UIAction(identifier: imagePickerButtonActionId) { [weak self] _ in
            print("picker action tapped...")
            guard let self else { return }
            self.router.navigateToEditPhotoViewController()
        }
        
        imagePickerButton.removeAction(identifiedBy: imagePickerButtonActionId, for: .touchUpInside)
        imagePickerButton.addAction(imagePickerButtonAction, for: .touchUpInside)
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
        
        viewModel.$selectedImage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self else { return }
                imagePickerButton.configue(image: image, photoState: .setImage)
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


extension DiaryCustomizerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        router.navigateToPickImageByCamera(picker: imagePicker)
    }
    
    func handleCameraSelection() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else  {
            router.navigateToShowAlert(title: "Camera Unavailable", message: "The camera is not available on this device.")
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                DispatchQueue.main.async {
                    if granted {
                        self.presentImagePicker(sourceType: .camera)
                    } else {
                        self.router.navigateToShowAlert(title: "Camera Permission Error", message: "Diary Recorder needs camera access to take photos. Please go to Settings to enable it.")
                    }
                }
            }
        case .authorized:
            presentImagePicker(sourceType: .camera)
        
        case .denied, .restricted:
            router.navigateToShowAlert(title: "Camera Permission Error", message: "Diary Recorder needs camera access to take photos. Please go to Settings to enable it.")
        @unknown default:
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        
//        if let edittedImage = info[.editedImage] as? UIImage {
//            viewModel.selectedImage = edittedImage
//        } else
//        
        guard  let originalImage = info[.originalImage] as? UIImage  else { return }
//            viewModel.selectedImage = originalImage
//        }
        
        dismiss(animated: true) { [unowned self] in
            router.navigateToImageCropViewController(image: originalImage)
        }
        
        print("We took pic successfully. \(viewModel.selectedImage)")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
}

extension DiaryCustomizerViewController {
    func handleGalleryWithPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        router.navigateToSelectImageGallery(picker: phPicker)
    }
    
    func handleGallerySelection() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            router.navigateToShowAlert(title: "Gallery Unavailable", message: "The gallery is not available on this device.")
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                guard let self else { return }
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.handleGalleryWithPHPicker()
                    } else {
                        self.router.navigateToShowAlert(title: "Gallery Permission Error", message: "Diary Recorder needs gallery access to select photos. Please go to Settings to enable it.")
                    }
                }
            }
        case .authorized, .limited:
            self.handleGalleryWithPHPicker()
            
        case .denied, .restricted:
            router.navigateToShowAlert(title: "Gallery Permission Error", message: "Diary Recorder needs gallery access to select photos. Please go to Settings to enable it.")
            
        @unknown default:
            break
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self)
        else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self.dismiss(animated: true) {
                        self.router.navigateToImageCropViewController(image: image)
                    }
                    print("We select pic successfully. \(self.viewModel.selectedImage)")
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func pickerDidCancel(_ picker: PHPickerViewController) {
        picker.dismiss(animated: true)
    }
}

extension DiaryCustomizerViewController {
    func deleteUserImage() {
        viewModel.selectedImage = UIImage(resource: .placeholderimage)
    }
}

extension DiaryCustomizerViewController: TOCropViewControllerDelegate {
    
    private func userDidPickImage(_ image: UIImage) {
        print("this is image from did pck image: \(image)")
        viewModel.selectedImage = image
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        userDidPickImage(image)
        dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true)
    }
}
