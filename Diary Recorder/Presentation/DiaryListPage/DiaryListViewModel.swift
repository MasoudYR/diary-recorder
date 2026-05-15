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
        dateFormatter.dateFormat = "yyyy MM dd HH:mm:ss"
        binding()
        
        
        //debug
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(7)) { [self] in
//            if let item = self.diaryListDataCollection.first {
//                do {
//                    print(">>>", Self.self, #function, "Deleting item: \(item.id)")
//                    try self.recordingsDetailsRealmManager.removeRecording(item)
//                    print(">>>", Self.self, #function, "Deleted item: \(item.id)")
//                } catch {
//                    print(">>>", Self.self, #function, "Deleting failed: \(error)")
//                }
//            }
//        }
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
//        if audioPlayerService.currentlyPlayingFileDetails?.id == diary.id {
//            AudioPlayerService.shared.stop()
//        }
        
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
