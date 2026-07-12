//
//  ImagePickerButton.swift
//  Diary Recorder
//
//  Created by Masoud on 7/12/26.
//

import Foundation
import UIKit

class ImagePickerButton: UIButton {
    
    private let parentView = UIView()
    private let diaryImageView = UIImageView()
    private let editPhotoView = UIView()
    private let editLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupMainImageSet()
    }
    
    private func setupMainImageSet() {
        parentView.isUserInteractionEnabled = false
        parentView.layer.cornerRadius = 20
        parentView.backgroundColor = .red
        parentView.clipsToBounds = true
        
        addSubview(parentView)
        
        parentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        //diaryImageView.image = UIImage(named: "placeholderimage")
        diaryImageView.contentMode = .scaleAspectFill
        diaryImageView.clipsToBounds = true
        
        parentView.addSubview(diaryImageView)
        
        diaryImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        editPhotoView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
        editPhotoView.layer.cornerRadius = 20
        
        parentView.addSubview(editPhotoView)
        
        editPhotoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        editLabel.text = "Edit"
        editLabel.font = .roundedFont(ofSize: 18, weight: .semibold)
        editLabel.textColor = .systemBackground
        editLabel.textAlignment = .center
        
        editPhotoView.addSubview(editLabel)
        
        editLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configue(image: UIImage?, photoState: PhotoState) {
        switch photoState {
        case .placeholder:
            diaryImageView.image = UIImage(resource: .placeholderimage)
        case .setImage:
            diaryImageView.image = image
        }
    }
}

enum PhotoState {
    case placeholder
    case setImage
}
