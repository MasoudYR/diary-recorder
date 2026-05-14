//
//  DiaryListViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import Combine

class DiaryListViewModel {
    
    @Published var diaryListDataCollection: [RecordingFileDetails] = []
    
    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    private var dateFormatter: DateFormatter?
    
    
    init() {
        readDiarylistData()
        self.dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "yyyy MM dd HH:mm:ss"
    }
    
    private func binding() {
        
    }
    
    func readDiarylistData() {
        do {
            try
            diaryListDataCollection = recordingsDetailsRealmManager.listRecordings()
            //recordingsDetailsRealmManager.removeAllRecordings()

        } catch {
            print("can not read diaries list")
        }
    }
    
    func changeDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600 / 60)
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        let timeString = String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)
        return timeString
    }
    
    func changeDateAndTime(_ date: Date) -> String {
        return self.dateFormatter?.string(from: date) ?? ""
    }
}
