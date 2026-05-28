//
//  NameDiaryViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/18/26.
//

import Foundation
import Combine

class NameDiaryViewModel {
    var text: String
    var lastsavedDiary:RecordingFileDetails
    
    private var nameCurrentValueSubject: PassthroughSubject<String, Never>
    
    init(lastSavedDiary:RecordingFileDetails, nameCurrentValueSubject: PassthroughSubject<String, Never>) {
        self.lastsavedDiary = lastSavedDiary
        self.nameCurrentValueSubject = nameCurrentValueSubject
        self.text = lastSavedDiary.name
    }
    
    func renameDiary() {
        guard !text.isEmpty else {
            //show error handle
            return
        }
        nameCurrentValueSubject.send(text)
    }
}
