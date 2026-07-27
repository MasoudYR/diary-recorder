//
//  CalendarViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 6/22/26.
//

import Foundation
import Combine
import UIKit


class CalendarViewModel {
    
    let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    @Published var dayDiariesList: [RecordingFileDetails] = []
    
    private let fileURLProvider: RecordingDiaryFileURLProvider = .default()
    var selectedDiary: RecordingFileDetails?
    var renameCurrentValueSubject: PassthroughSubject<String, Never> = .init()
    
    var updateDetailsCurrentValueSubject: PassthroughSubject<UpdateDetails, Never> = .init()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        binding()
    }
    
    private func binding() {
        updateDetailsCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] details in
                guard let self else { return }
                editDiaryDetails(
                    newName: details.name,
                    newImage: details.imageFileName,
                    newMood: details.mood,
                    newText: details.text
                )
                
                guard let selectedDiary else { return }
                getOneDayDiareiesList(date: selectedDiary.date)
            }
            .store(in: &cancellables)
    }
    
    func getOldestDiaryDate() -> Date {
        return recordingsDetailsRealmManager.getOldestDate()
    }
    
    func getOneDayDiareiesList(date: Date)  {
        let data = recordingsDetailsRealmManager.getDiariesOfOneDay(date: date)
        dayDiariesList = data
        print("!!!!!!!!!!!!!!! this is dateDiaries that is selected: \(data)")
    }
    
    func transformTimeToString(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600 / 60)
        let seconds = Int(duration) % 60
        //let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return timeString
    }
    
    func changeDateAndTime(_ date: Date) -> String {
        return dateFormatter.string(from: date)
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
    
    func editDiaryDetails(newName: String, newImage: String, newMood: String, newText: String) {
        guard let selectedDiary else { return }
        
        do {
            try recordingsDetailsRealmManager.updateDiary(
                diary: selectedDiary,
                newName: newName,
                newImage: newImage,
                newMood: newMood,
                newText: newText
            )
        } catch {
            print("you can no tupdate your diary: \(error)")
            //handle error alert
        }
    }
}
