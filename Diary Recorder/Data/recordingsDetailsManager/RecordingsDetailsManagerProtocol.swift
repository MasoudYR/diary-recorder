//
//  RecordingsDetailsManagerProtocol.swift
//  Diary Recorder
//
//  Created by Masoud on 5/10/26.
//

import Foundation

enum SaveRecordingError: Error {
    case failedToSave
    case recordingAlreadyExists
}

enum RemoveRecordingError: Error {
    case failedToRemove
    case recordingNotFound
}
enum RenameRecordingError: Error {
    case failedToRename
    case recordingNotFound
}
enum ListRecordingError: Error {
    case failedToList
}

protocol RecordingModifierHandler {
    func saveRecording(_ recording: RecordingFileDetails) throws(SaveRecordingError)
    func removeRecording(withID recordingID: UUID) throws(RemoveRecordingError)
    func removeAllRecordings() throws(RemoveRecordingError)
    func renameRecording(_ recording: RecordingFileDetails, to newName: String) throws(RenameRecordingError)
}

extension RecordingModifierHandler {
    func removeRecording(_ recording: RecordingFileDetails) throws(RemoveRecordingError) {
        try removeRecording(withID: recording.id)
    }
}

protocol ListRecordingHandler {
    func listRecordings() throws(ListRecordingError) -> [RecordingFileDetails]
}

protocol RecordingsManager: RecordingModifierHandler, ListRecordingHandler {
    
}
