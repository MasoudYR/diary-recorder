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
    
    private var dateFormatter: DateFormatter
    private var nameCurrentValueSubject: PassthroughSubject<String, Never>
    
    init(nameCurrentValueSubject: PassthroughSubject<String, Never>) {
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = Date()
        let formattedDate = dateFormatter.string(from: date)
        self.text = "Diary \(formattedDate)"
        self.nameCurrentValueSubject = nameCurrentValueSubject
    }
    
    func saveDiary() {
        guard let text, !text.isEmpty else {
            //show error handle
            return
        }
        nameCurrentValueSubject.send(text)
    }
}
