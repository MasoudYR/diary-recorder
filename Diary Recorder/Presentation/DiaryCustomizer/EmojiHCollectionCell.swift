//
//  EmojiHCollectionCell.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit

class EmojiHCollectionCell: UICollectionViewCell {
    
    static let identifier: String = "EmojiHCollectionCell"
    
    private let emojiImageView = UIImageView()
    
    private let arrayEmoji: [EmojiModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(emojiImageView)
        emojiImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.edges.equalToSuperview()
        }
    }
    
    func configue(image: UIImage) {
        self.emojiImageView.image = image
    }
}


