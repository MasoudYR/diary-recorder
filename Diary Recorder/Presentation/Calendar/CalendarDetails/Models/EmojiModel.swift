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

enum EmojiType {
    case sunnysmile
    case sideeye
    case ragemode
    case lol
    case kissy
    case hearteye
    case cuty
    case grin
    case biggrin
    case sillydead
    case wowface
    case eyeroll
    case bleh
    case pokerface
    case cry
    case bluemode
    case frustrated
}
