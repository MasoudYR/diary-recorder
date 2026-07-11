//
//  DiaryCustomizerViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit

class DiaryCustomizerViewModel {
    
    var emojiArray: [EmojiModel] = []
    
    @Published var selectedEmoji: IndexPath?
    
    init() {
        setupArrayEmoji()
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
