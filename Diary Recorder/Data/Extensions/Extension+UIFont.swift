//
//  Extension+UIFont.swift
//  Diary Recorder
//
//  Created by Masoud on 6/1/26.
//

import Foundation
import UIKit

extension UIFont {
    
    static func roundedFont(ofStyle style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let fontSize = UIFont.preferredFont(forTextStyle: style).pointSize
        
        return if let descriptor = UIFont.systemFont(ofSize: fontSize, weight: weight).fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: fontSize)
        } else {
            UIFont.preferredFont(forTextStyle: style)
        }
    }
    
    static func roundedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        if let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: size)
        } else {
            UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    
    static func monospacedRoundedSystemFont2(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        return if let descriptor = UIFont.monospacedSystemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: size)
        } else {
            UIFont.systemFont(ofSize: size, weight: .black)
            
        }
    }
    
    static func monospacedRoundedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        // Start with rounded system font (not monospaced)
        guard let roundedDescriptor = UIFont.systemFont(ofSize: size, weight: weight)
            .fontDescriptor
            .withDesign(.rounded) else {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }

        // Manually add monospaced digit feature settings
        let monospacedDescriptor = roundedDescriptor.addingAttributes([
            .featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                    UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector
                ]
            ]
        ])

        return UIFont(descriptor: monospacedDescriptor, size: size)
    }
    
}

func aa() {
    let label = UILabel()
    label.font = .roundedFont(ofSize: 24, weight: .bold)
}
