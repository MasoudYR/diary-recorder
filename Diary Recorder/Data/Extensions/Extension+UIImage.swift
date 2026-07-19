//
//  Extension+UIImage.swift
//  Diary Recorder
//
//  Created by Masoud on 7/19/26.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
