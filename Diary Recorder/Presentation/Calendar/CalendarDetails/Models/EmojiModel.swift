//
//  EmojiModel.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit

struct EmojiModel {
    let grayscaleImage: UIImage
    let colorImage: UIImage
    let type: EmojiType
}

enum EmojiType: String, CaseIterable {
    case sunnysmile = "sunnysmile"
    case sideeye = "sideeye"
    case ragemode = "ragemode"
    case lol = "lol"
    case kissy = "kissy"
    case hearteye = "hearteye"
    case cuty = "cuty"
    case grin = "grin"
    case biggrin = "biggrin"
    case sillydead = "sillydead"
    case wowface = "wowface"
    case eyeroll = "eyeroll"
    case bleh = "bleh"
    case pokerface = "pokerface"
    case cry = "cry"
    case bluemode = "bluemode"
    case frustrated = "frustrated"
}
