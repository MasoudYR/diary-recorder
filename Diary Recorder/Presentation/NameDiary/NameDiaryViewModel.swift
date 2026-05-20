//
//  NameDiaryViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/18/26.
//

import Foundation
import Combine

class NameDiaryViewModel {
    @Published var text: String?
    
    init() {
        
    }
    
    private func textLimit() {
        guard let text, !text.isEmpty else {
            //show error handle
            return
        }
        
        let number  = text?.count
    }
}
