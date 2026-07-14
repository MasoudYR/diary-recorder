//
//  DiaryCustomizerRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import PhotosUI

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
    
    
    func navigateToEditPhotoViewController() {
        guard let diaryCustomizerViewController else { return }
        
        let viewController = EditPhotoViewController.make(editPhotoHandler: { [weak self] editType in
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
}
