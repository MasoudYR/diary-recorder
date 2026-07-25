//
//  DiaryCustomizerRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import PhotosUI
import CropViewController

class DiaryCustomizerRouter {
    weak var diaryCustomizerViewController: DiaryCustomizerViewController?
    
    init() {
        
    }
    
    func navigateToShowAlert(title: String, message: String) {
        guard let diaryCustomizerViewController else { return }
        let viewController = AlertViewController()
        viewController.config(title: title, message: message)
        diaryCustomizerViewController.present(viewController, animated: true)
    }
    
    
    func navigateToEditPhotoViewController(isDefaultImage: Bool) {
        guard let diaryCustomizerViewController else { return }
        
        let viewController = EditPhotoViewController.make(
            isDefaultImage: isDefaultImage,
            editPhotoHandler: { [weak self] editType in
                guard let self else { return }
                
                print("this is edit Type inside DiaryCustomizerRouter: \(editType)")
                
                switch editType {
                case .selectFromGallery:
                    diaryCustomizerViewController.handleGallerySelection()
                case .takePhotoByCamera:
                    diaryCustomizerViewController.handleCameraSelection()
                case .deletePhoto:
                    navigateToDeleteImage()
                }
            }
        )
        
        if let sheet  = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in return 250 }]
        }
        
        diaryCustomizerViewController.present(viewController, animated: true)
    }
    
    func navigateToPickImageByCamera(picker: UIImagePickerController){
        guard let diaryCustomizerViewController else { return }
        
        diaryCustomizerViewController.present(picker, animated: true)
    }
    
    func navigateToSelectImageGallery(picker: PHPickerViewController){
        guard let diaryCustomizerViewController else { return }
        
        diaryCustomizerViewController.present(picker, animated: true)
    }
    
    func navigateToDeleteImage() {
        guard let diaryCustomizerViewController else { return }
        let deleteViewController = DeleteAlertViewController.make(title: "Delete Alert", message: "Do you want to delete your diary image?") {
            print("image deleted")
            diaryCustomizerViewController.deleteUserImage()
        }
        
        diaryCustomizerViewController.present(deleteViewController, animated: true)
    }
    
    func navigateToImageCropViewController(image: UIImage) {
        guard let diaryCustomizerViewController
        //let navigationController = diaryCustomizerViewController.navigationController
        else { return }
        let cropController = CropViewController(image: image)
        cropController.aspectRatioPreset = .init(width: image.size.width, height: image.size.width)
        cropController.aspectRatioLockEnabled = true
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetButtonHidden = true
        cropController.delegate = diaryCustomizerViewController
        cropController.transitioningDelegate = nil
        diaryCustomizerViewController.present(cropController, animated: true)
    }
}
