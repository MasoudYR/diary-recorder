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
    private let fileURLProvider: RecordingDiaryFileURLProvider
    
    var selectedDiary: RecordingFileDetails?
    var renameCurrentValueSubject: PassthroughSubject<String, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    
    init(fileURLProvider: RecordingDiaryFileURLProvider = .default()) {
        self.fileURLProvider = fileURLProvider
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        binding()
    }
    
    private func binding() {
        recordingsDetailsRealmManager
            .getAllDiariesWithPublisher()
            .sink { completion in
                switch completion {
                case .finished:
                    ()
                case .failure(_):
                    ()
                }
            } receiveValue: { list in
                print(">>>", Self.self, #function, "count: \(list.count)")
                self.diaryListDataCollection = list
            }
            .store(in: &cancellables)
        
        renameCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                guard let self else { return }
                self.rename(name: name)
            }
            .store(in: &cancellables)
    }
    
    func delete(diary: RecordingFileDetails) {
        print("delete action function inside diarylistviewmodel is called")
        print("diarylistdatacollection count: \(diaryListDataCollection.count)")
        do {
            try recordingsDetailsRealmManager.removeDiary(withID: diary.id)
        } catch {
            print("Delete failed: \(error)")
            switch error {
            case .diaryNotFound:
                //handle showing alert
                ()
            case .failedToRemove:
                //handle showing alert
                ()
            default:
                break
            }
        }
    }
    
    func share(diary: RecordingFileDetails) -> URL? {
        let url = fileURLProvider.makeDiaryFileURL(named: diary.fileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }
    
    func transformTimeToString(_ duration: TimeInterval) -> String {
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
    
    func rename(name: String) {
        guard let selectedDiary else { return }
        do {
            try recordingsDetailsRealmManager.renameDiary(diary: selectedDiary, to: name)
        } catch {
            print("rename diary Error: \(error)")
            switch error {
            case .diaryNotFound:
                //handle showing alert
                ()
            case .failedToRename:
                //handle showing alert
                ()
            default:
                break
            }
        }
    }
}
