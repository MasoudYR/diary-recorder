//
//  DiaryCustomizerViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import Combine

class DiaryCustomizerViewModel {
    
    @Published var selectedEmoji: IndexPath?
    @Published var selectedImage: UIImage?
    @Published var textDiary: String?
    @Published private(set) var textDiaryCount: String = ""
    
    var nameDiary: String = ""
    //var textDiary: String = ""
    
    var emojiArray: [EmojiModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupArrayEmoji()
        binding()
    }
    
    private func binding() {
        $textDiary
            .compactMap { $0 }
            .sink { [unowned self] text in
                self.textDiaryCount = "\(text.count)/\(150)"
            }
            .store(in: &cancellables)
    }
    
    private func setupArrayEmoji() {
        emojiArray = [
            EmojiModel(
                grayscaleImage: UIImage(resource: .sunnysmile),
                colorImage: UIImage(resource: .colorsunnysmile),
                type: .sunnysmile
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .grin),
                colorImage: UIImage(resource: .colorgrin),
                type: .grin
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .biggrin),
                colorImage: UIImage(resource: .colorbiggrin),
                type: .biggrin
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .lol),
                colorImage: UIImage(resource: .colorlol),
                type: .lol
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .cuty),
                colorImage: UIImage(resource: .colorcuty),
                type: .cuty
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .bleh),
                colorImage: UIImage(resource: .colorbleh),
                type: .bleh
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .sillydead),
                colorImage: UIImage(resource: .colorsillydead),
                type: .sillydead
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .hearteye),
                colorImage: UIImage(resource: .colorhearteye),
                type: .hearteye
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .kissy),
                colorImage: UIImage(resource: .colorkissy),
                type: .kissy
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .pokerface),
                colorImage: UIImage(resource: .colorpokerface),
                type: .pokerface
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .eyeroll),
                colorImage: UIImage(resource: .coloreyeroll),
                type: .eyeroll
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .sideeye),
                colorImage: UIImage(resource: .colorsideeye),
                type: .sideeye
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .bluemode),
                colorImage: UIImage(resource: .colorbluemode),
                type: .bluemode
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .cry),
                colorImage: UIImage(resource: .colorcry),
                type: .cry
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .wowface),
                colorImage: UIImage(resource: .colorwowface),
                type: .wowface
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .frustrated),
                colorImage: UIImage(resource: .colorfrustrated),
                type: .frustrated
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .ragemode),
                colorImage: UIImage(resource: .colorragemode),
                type: .ragemode
            ),
        ]
    }
}
