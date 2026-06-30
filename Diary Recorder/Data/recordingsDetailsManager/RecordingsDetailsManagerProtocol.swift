//
//  RecordingsDetailsManagerProtocol.swift
//  Diary Recorder
//
//  Created by Masoud on 5/10/26.
//

import Foundation
import Combine

enum RealmError: Error {
    case failedToSave
//    case diaryNotFound
    case failedToRemove
    case failedToRename
    case failedToGetList
    
    var description: String {
        switch self {
        case .failedToSave:
            "Failed to save diary."
//        case .diaryNotFound:
//            "Your diary not Found."
        case .failedToRemove:
            "Failed to remove diary."
        case .failedToRename:
            "Failed to rename diary."
        case .failedToGetList:
            "Failed to get diaries."
        }
    }
}

protocol RecordingModifierHandler {
    func saveDiary(diary: RecordingFileDetails) throws(RealmError)
    func removeDiary(withID recordingID: UUID) throws(RealmError)
    func removeAllDiaries() throws(RealmError)
    func renameDiary(diary: RecordingFileDetails, to newName: String) throws(RealmError)
}

extension RecordingModifierHandler {
    func removeDiary(diary: RecordingFileDetails) throws(RealmError) {
        try removeDiary(withID: diary.id)
    }
}

protocol ListRecordingHandler {
    func getAllDiariesList() -> [RecordingFileDetails]
    func getAllDiariesWithPublisher() -> AnyPublisher<[RecordingFileDetails], RealmError>
    func getAllDiariesDataGroupedByDate(startDate: Date, endDate: Date) -> [Date: Int]
    func getNumberOfDiariesInDaysOfOneMonth(date: Date) throws(RealmError) -> [Date: Int]
    func getNumberOfDiariesInOneDay(date: Date) -> Int
    func getDiariesOfOneDay(date: Date) -> [RecordingFileDetails]
    func getOldestDate() -> Date
}

protocol RecordingsManager: RecordingModifierHandler, ListRecordingHandler {
    
}
