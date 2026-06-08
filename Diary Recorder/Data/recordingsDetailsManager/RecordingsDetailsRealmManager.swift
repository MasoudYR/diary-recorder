//
//  RecordingsDetailsManager.swift
//  Diary Recorder
//
//  Created by Masoud on 5/11/26.
//

import Foundation
import RealmSwift
import Combine

public final class RecordingsDetailsRealmManager {
    
    public static var shared: RecordingsDetailsRealmManager { 
        return RecordingsDetailsRealmManager(fileURLProvider: .default())
    }
    
    var realm: Realm {
        getRealmObject()
    }
    
    private let fileURLProvider: RecordingDiaryFileURLProvider
    private var tokens: [NotificationToken] = []
    
    private init(fileURLProvider: RecordingDiaryFileURLProvider) {
        self.fileURLProvider = fileURLProvider
    }
    
    deinit {
        tokens.forEach {
            $0.invalidate()
        }
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
        print("this is string url of the fil &&&&: \(recording.fileName)")
        let realmInstance = RecordingsDetailsRealmModel(
            identifier: recording.id,
            fileName: recording.fileName,
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
        
        let fileName = realmInstance.fileName
        print(">>>>>>>>>> my file url to delete is: \(fileName)")
        realm.safeWrite {
            realm.delete(realmInstance)
        }
        
        do {
            let url = fileURLProvider.makeDiaryFileURL(named: fileName)
            try FileManager.default.removeItem(at: url)
        } catch (let error) {
            print("delete file from the file manager doesnt work because: \(error)")
        }
    }
    
    func removeAllRecordings() throws(RemoveRecordingError) {
        let realm = self.realm
        realm.safeWrite {
            realm.deleteAll()
        }
        
        // TODO: remove all files
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
        
        let realmData = realm
            .objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: false)
        print("this is list of realm data: %%%%: \(realmData)")
        
        return realm
            .objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: false)
            .map {
                let sample = RecordingFileDetails(
                    id: $0.identifier,
                    fileName: $0.fileName,
                    name: $0.name,
                    date: $0.date,
                    duration: $0.duration
                )
                
                print("this is list of mapppppeeedddd realm data: @@@@@: \(sample)")
                return sample
            }
    }
    
    func listRecordingsPublisher() -> AnyPublisher<[RecordingFileDetails], ListRecordingError> {
        let results = realm
            .objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: false)
        
        print("this is list of realm data: %%%%: \(results)")
        
        let subject = PassthroughSubject<[RecordingFileDetails], ListRecordingError>()
        let token = results.observe { changes in
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                subject.send(
                    Array(
                        results.map {
                            let sample = RecordingFileDetails(
                                id: $0.identifier,
                                fileName: $0.fileName,
                                name: $0.name,
                                date: $0.date,
                                duration: $0.duration
                            )
                            print("this is list of mapppppeeedddd realm data: @@@@@: \(sample)")
                            return sample
                        }
                    )
                )
            case .error:
                subject.send(completion: .failure(.failedToList))
            }
        }
        tokens.append(token)
        return subject.eraseToAnyPublisher()
    }
    
    func getNumberOfDaysRecordsInMonth(date: Date) throws -> [Date: Int] {
        
        let calendar = Calendar(identifier: .gregorian)
        
        var currentMonthComponents = calendar.dateComponents([.year, .month], from: date)
        currentMonthComponents.day = 1
        let currentMonth = calendar.date(from: currentMonthComponents)!
        
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        
        let results = realm
            .objects(RecordingsDetailsRealmModel.self)
            .where { $0.date >= currentMonth && $0.date < nextMonth }
        
        print("%%%%%% this is results in func getNumberOfDaysRecordsInMonth: \(results)")
            
        var grouped: [Date: Int] = [:]
        
        for record in results {
            let dayKey = calendar.startOfDay(for: record.date)
            print("******************* this is keyDay: \(dayKey)")
            grouped[dayKey, default: 0] += 1
        }
        return grouped
    }
}
