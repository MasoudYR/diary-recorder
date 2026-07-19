//
//  EditPhotoViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 7/12/26.
//

import Foundation
import UIKit
//import AVFoundation
//import Photos
//import PhotosUI

class EditPhotoViewController: UIViewController {
    
    private let viewModel: EditPhotoViewModel
    private let router: EditPhotoRouter
    
    private let diaryPhotoLabel = UILabel()
    private let closeButton = UIButton()
    private let editPhotoTableView = UITableView(frame: .zero, style: .insetGrouped)
//    private let imagePicker = UIImagePickerController()
    
    private let isDefaultImage: Bool
    
    init(viewModel: EditPhotoViewModel, router: EditPhotoRouter, isDefaultImage: Bool) {
        self.viewModel = viewModel
        self.router = router
        self.isDefaultImage = isDefaultImage
        super.init(nibName: nil, bundle: nil)
        self.router.editPhotoViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make(isDefaultImage: Bool, editPhotoHandler: @escaping (_ editType: editPhotoType) -> Void) -> EditPhotoViewController {
        let viewModel = EditPhotoViewModel()
        let router = EditPhotoRouter(editPhotoHandler: editPhotoHandler)
        let viewController = EditPhotoViewController(viewModel: viewModel, router: router, isDefaultImage: isDefaultImage)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .main
        setupDiaryPhotoLabel()
        setupCloseButton()
        setupEditPhotoTableView()
    }
    
    private func setupDiaryPhotoLabel() {
        diaryPhotoLabel.text = "Edit Diary Photo"
        diaryPhotoLabel.font = .roundedFont(ofSize: 20, weight: .semibold)
        diaryPhotoLabel.textColor = .label
        diaryPhotoLabel.textAlignment = .center
        
        view.addSubview(diaryPhotoLabel)
        
        diaryPhotoLabel.snp.makeConstraints { make in
            //make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCloseButton() {
        let largeConfigue = UIImage.SymbolConfiguration(weight: .bold)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: largeConfigue), for: .normal)
        closeButton.tintColor = .systemGray
        closeButton.backgroundColor = .systemBackground
        closeButton.layer.cornerRadius = 15
        
        view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(diaryPhotoLabel)
        }
        
        let closeButtonActionId = UIAction.Identifier("closeButtonActionId")
        let closeButtonAction = UIAction(identifier: closeButtonActionId) { [weak self] _ in
            guard let self else { return }
            print("close button tapped")
            self.dismiss(animated: true)
        }
        
        closeButton.removeAction(identifiedBy: closeButtonActionId, for: .touchUpInside)
        closeButton.addAction(closeButtonAction, for: .touchUpInside)
    }
    
    private func setupEditPhotoTableView() {
        editPhotoTableView.delegate = self
        editPhotoTableView.dataSource = self
        editPhotoTableView.rowHeight = 50
        editPhotoTableView.register(EditPhotoTableViewCell.self, forCellReuseIdentifier: EditPhotoTableViewCell.identifier)
        
        editPhotoTableView.backgroundColor = .clear
        editPhotoTableView.showsVerticalScrollIndicator = false
        editPhotoTableView.isScrollEnabled = false
        
        //...
        //editPhotoTableView.sectionHeaderHeight = 20
        //editPhotoTableView.sectionFooterHeight = 5
        
        view.addSubview(editPhotoTableView)
        
        editPhotoTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(closeButton.snp.bottom).offset(5)
        }
    }
}

extension EditPhotoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isDefaultImage ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDefaultImage {
            return 2
        } else {
            return section == 0 ? 2 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditPhotoTableViewCell.identifier, for: indexPath) as! EditPhotoTableViewCell
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.configue(title: "Take photo", iconImage: UIImage(systemName: "camera")!, tintColor: .label)
            } else {
                cell.configue(title: "Choose photo", iconImage: UIImage(systemName: "photo")!, tintColor: .label)
            }
        case 1:
            cell.configue(title: "Delete photo", iconImage: UIImage(systemName: "trash")!, tintColor: .systemRed)
        default:
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                print("take photo is selected")
                //handleCameraSelection()
                self.router.navigateToTakeOrGetOrDeletePhoto(editType: .takePhotoByCamera)
            } else {
                print("choose photo is selected")
                //handleGallerySelection()
                self.router.navigateToTakeOrGetOrDeletePhoto(editType: .selectFromGallery)
            }
        case 1:
            print("delete photo is selected")
            self.router.navigateToTakeOrGetOrDeletePhoto(editType: .deletePhoto)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }
}

//extension EditPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
//        imagePicker.sourceType = sourceType
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        
//        router.navigateToPickImage(picker: imagePicker)
//    }
//    
//    func handleCameraSelection() {
//        
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else  {
//            router.navigateToShowAlert(title: "Camera Unavailable", message: "The camera is not available on this device.")
//            return
//        }
//        
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//        
//        switch status {
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                guard let self else { return }
//                DispatchQueue.main.async {
//                    if granted {
//                        self.presentImagePicker(sourceType: .camera)
//                    } else {
//                        self.router.navigateToShowAlert(title: "Camera Permission Error", message: "Diary Recorder needs camera access to take photos. Please go to Settings to enable it.")
//                    }
//                }
//            }
//        case .authorized:
//            presentImagePicker(sourceType: .camera)
//        
//        case .denied, .restricted:
//            router.navigateToShowAlert(title: "Camera Permission Error", message: "Diary Recorder needs camera access to take photos. Please go to Settings to enable it.")
//        @unknown default:
//            break
//        }
//    }
//    
//    func handleGallerySelection() {
//        
//        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
//            router.navigateToShowAlert(title: "Gallery Unavailable", message: "The gallery is not available on this device.")
//            return
//        }
//        
//        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//        
//        switch status {
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
//                guard let self else { return }
//                DispatchQueue.main.async {
//                    if newStatus == .authorized || newStatus == .limited {
//                        self.presentImagePicker(sourceType: .photoLibrary)
//                    } else {
//                        self.router.navigateToShowAlert(title: "Gallery Permission Error", message: "Diary Recorder needs gallery access to select photos. Please go to Settings to enable it.")
//                    }
//                }
//            }
//        case .authorized, .limited:
//            presentImagePicker(sourceType: .photoLibrary)
//            
//        case .denied, .restricted:
//            router.navigateToShowAlert(title: "Gallery Permission Error", message: "Diary Recorder needs gallery access to select photos. Please go to Settings to enable it.")
//            
//        @unknown default:
//            break
//        }
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        imagePicker.dismiss(animated: true)
//        
//        if let edittedImage = info[.editedImage] as? UIImage {
//            viewModel.selectedImage = edittedImage
//        } else if let originalImage = info[.originalImage] as? UIImage {
//            viewModel.selectedImage = originalImage
//        }
//        
//        print("We took pic successfully. \(viewModel.selectedImage)")
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        imagePicker.dismiss(animated: true)
//    }
//}

//extension EditPhotoViewController: PHPickerViewControllerDelegate {
//    
//    func handleGalleryWithPHPicker() {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 1
//        config.filter = .images
//        
//        let phPicker = PHPickerViewController(configuration: config)
//        phPicker.delegate = self
//        
//        router.navigateToSelectImage(picker: phPicker)
//    }
//    
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        
//        guard let provider = results.first?.itemProvider,
//              provider.canLoadObject(ofClass: UIImage.self)
//        else { return }
//        
//        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//            guard let self else { return }
//            DispatchQueue.main.async {
//                if let image = image as? UIImage {
//                    self.viewModel.selectedImage = image
//                    
//                    print("We select pic successfully. \(self.viewModel.selectedImage)")
//                }
//            }
//        }
//    }
//    
//    func pickerDidCancel(_ picker: PHPickerViewController) {
//        picker.dismiss(animated: true)
//    }
//}

enum editPhotoType {
    case selectFromGallery
    case takePhotoByCamera
    case deletePhoto
}
