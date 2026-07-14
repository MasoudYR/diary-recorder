//
//  ImagePickerRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 7/12/26.
//

import Foundation
import UIKit
import PhotosUI

class EditPhotoRouter {
    weak var editPhotoViewController: EditPhotoViewController?
    
    private let editPhotoHandler: (_ editType: editPhotoType) -> Void
    
    init(editPhotoHandler: @escaping (_ editType: editPhotoType) -> Void){
        self.editPhotoHandler = editPhotoHandler
    }
    
    func navigateToTakeOrGetOrDeletePhoto(editType: editPhotoType) {
        guard let editPhotoViewController else { return }
        print("#######this is edit TYpe: \(editType)")
        editPhotoViewController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.editPhotoHandler(editType)
        }
    }
    
//    func navigateToShowAlert(title: String, message: String) {
//        guard let editPhotoViewController else { return }
//        let viewController = AlertViewController()
//        viewController.config(title: title, message: message)
//        editPhotoViewController.present(viewController, animated: true)
//    }
//    
//    func navigateToPickImage(picker: UIImagePickerController){
//        guard let editPhotoViewController
//              //let navigationController = editPhotoViewController.navigationController
//        else { return }
//        
//        editPhotoViewController.present(picker, animated: true)
//    }
//    
//    func navigateToSelectImage(picker: PHPickerViewController){
//        guard let editPhotoViewController
//              //let navigationController = editPhotoViewController.navigationController
//        else { return }
//        
//        editPhotoViewController.present(picker, animated: true)
//    }
    
}
