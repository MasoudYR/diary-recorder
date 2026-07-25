//
//  DiaryListViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import Combine
import RealmSwift
import UIKit

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
            if error ==  .failedToRemove {
                //handle showing alert
            }
        }
    }
    
    func share(diary: RecordingFileDetails) -> URL? {
        let url = fileURLProvider.makeFileURL(named: diary.fileName)
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
            if error ==  .failedToRemove {
                //handle showing alert
            }
        }
    }
    
    func getImageOfDiary(diary: RecordingFileDetails) -> UIImage {
        let defaultImage = UIImage(resource: .placeholderimage)
        if !diary.imageFileName.isEmpty {
            let imageURL = fileURLProvider.makeFileURL(named: diary.imageFileName)
            guard FileManager.default.fileExists(atPath: imageURL.path) else {
                print("Image file doesn't exist")
                return defaultImage
            }
            
            do {
                let data = try Data(contentsOf: imageURL)
                if let image = UIImage(data: data) {
                    return image
                } else {
                    return defaultImage
                }
            } catch {
                print("We cannot make image of diary by data")
                return defaultImage
            }
        } else {
            print("Diary has no image.")
            return defaultImage
        }
    }
    
    func getEmojiOfDiary(diary: RecordingFileDetails) -> UIImage {
        //let emoji = EmojiType(rawValue: diary.mood)
        if let emojiImage = UIImage(named: diary.mood) {
            return emojiImage
        } else {
            return UIImage(resource: .pokerface)
        }
    }
}
