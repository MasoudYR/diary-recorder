//
//  Calendar3ViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 6/22/26.
//

import Foundation



class Calendar3ViewModel {
    
    let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    @Published private(set) var dayDiariesList: [RecordingFileDetails] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    init() {
        
    }
    
    func getOneDayDiareiesList(date: Date)  {
        let data = try! recordingsDetailsRealmManager.getDiariesOfOneDate(date: date)
        dayDiariesList = data
        print("!!!!!!!!!!!!!!! this is dateDiaries that is selected: \(data)")
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
}
