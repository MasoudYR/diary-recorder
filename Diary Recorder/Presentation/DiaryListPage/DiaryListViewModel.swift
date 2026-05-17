//
//  DiaryListViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import Combine
import RealmSwift

class DiaryListViewModel {
    
    @Published var diaryListDataCollection: [RecordingFileDetails] = []
    
    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    private var dateFormatter: DateFormatter
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        //readDiarylistData()
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        binding()
    }
    
    private func binding() {
        recordingsDetailsRealmManager
            .listRecordingsPublisher()
            .sink { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    ()
                }
            } receiveValue: { list in
                print(">>>", Self.self, #function, "count: \(list.count)")
                self.diaryListDataCollection = list
            }
            .store(in: &cancellables)
    }
    
    func readDiarylistData() {
        
    }
    
    func delete(_ diary: RecordingFileDetails) {
        print("delete action function inside diarylistviewmodel is called")
        print("diarylistdatacollection count: \(diaryListDataCollection.count)")
        do {
            try recordingsDetailsRealmManager.removeRecording(withID: diary.id)
        } catch {
            print("Delete failed: \(error)")
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
        return dateFormatter.string(from: date)
    }
}
