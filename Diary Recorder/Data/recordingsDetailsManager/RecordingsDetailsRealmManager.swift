//
//  RecordingsDetailsManager.swift
//  Diary Recorder
//
//  Created by Masoud on 5/11/26.
//

import Foundation
import RealmSwift

public final class RecordingsDetailsRealmManager {
    
    public static var shared: RecordingsDetailsRealmManager {
        return RecordingsDetailsRealmManager()
    }
    
    var realm: Realm {
        getRealmObject()
    }
    
    private init() {
        
    }
    
    private func getRealmObject() -> Realm {
        var config = Realm.Configuration()
        config.schemaVersion = 1
        config.migrationBlock = { _, _ in }
        Realm.Configuration.defaultConfiguration = config
        return try! Realm()
    }
}

extension RecordingsDetailsRealmManager: RecordingModifierHandler {
    
    func saveRecording(_ recording: RecordingFileDetails) throws(SaveRecordingError) {
        let realm = self.realm
        let stringURL = recording.fileURL.absoluteString
        let realmInstance = RecordingsDetailsRealmModel(
            identifier: recording.id,
            fileURL: stringURL,
            name: recording.name,
            date: recording.date,
            duration: recording.duration
        )
        realm.safeWrite {
            realm.add(realmInstance)
            print("ADD RecordingsDetailsRealm:", recording.id )
        }
    }
    
    func removeRecording(withID recordingID: UUID) throws(RemoveRecordingError) {
        let realm = self.realm
        guard let realmInstance = realm.object(ofType: RecordingsDetailsRealmModel.self, forPrimaryKey: recordingID) else {
            throw .recordingNotFound
        }
        realm.safeWrite {
            realm.delete(realmInstance)
        }
    }
    
    func removeAllRecordings() throws(RemoveRecordingError) {
        let realm = self.realm
        realm.safeWrite {
            realm.deleteAll()
        }
    }
    
    func renameRecording(_ recording: RecordingFileDetails, to newName: String) throws(RenameRecordingError) {
        let realm = self.realm
        
        guard let realmInstance = realm.object(ofType: RecordingsDetailsRealmModel.self, forPrimaryKey: recording.id) else {
            throw .recordingNotFound
        }
        
        realm.safeWrite {
            realmInstance.name = newName
        }
    }
}

extension RecordingsDetailsRealmManager: ListRecordingHandler {
    func listRecordings() throws(ListRecordingError) -> [RecordingFileDetails] {
        let realm = self.realm
        
        return realm
            .objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: false)
            .map {
                RecordingFileDetails(
                    id: $0.identifier,
                    fileURL: URL(filePath: $0.fileURL),
                    name: $0.name,
                    date: $0.date,
                    duration: $0.duration
                )
            }
    }
}
