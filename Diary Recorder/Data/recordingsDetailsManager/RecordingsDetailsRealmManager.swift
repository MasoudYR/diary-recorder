//
//  RecordingsDetailsManager.swift
//  Diary Recorder
//
//  Created by Masoud on 5/11/26.
//

import Foundation
import RealmSwift
import Combine
import UIKit

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
        
        print(">>>>", Self.self, config.fileURL)
        return try! Realm()
    }
}

extension RecordingsDetailsRealmManager: RecordingModifierHandler {
    
    func saveDiary(diary: RecordingFileDetails) throws(RealmError) {
        let realm = self.realm
        
        print("this is string url of the fil &&&&: \(diary.fileName)")
        let realmInstance = RecordingsDetailsRealmModel(
            identifier: diary.id,
            fileName: diary.fileName,
            name: diary.name,
            imageFileName: diary.imageFileName,
            date: diary.date,
            duration: diary.duration,
            mood: diary.mood,
            text: diary.text
        )
        
        do {
            try realm.safeWrite {
                realm.add(realmInstance)
                print("ADD RecordingsDetailsRealm:", diary.id )
            }
        } catch {
            throw .failedToSave
        }
    }
    
    func removeDiary(withID diaryID: UUID) throws(RealmError) {
        let realm = self.realm
        
        guard let realmInstance = realm.object(ofType: RecordingsDetailsRealmModel.self, forPrimaryKey: diaryID) else {
            throw .failedToRemove
        }
        
        let fileName = realmInstance.fileName
        let imageFileName = realmInstance.imageFileName
        print(">>>>>>>>>> my file url to delete is: \(fileName)")
        print(">>>>>>>>>> my file url to delete is: \(imageFileName)")
        
        do {
            try realm.safeWrite {
                realm.delete(realmInstance)
            }
        } catch {
            throw .failedToRemove
        }

        do {
            let url = fileURLProvider.makeFileURL(named: fileName)
            try FileManager.default.removeItem(at: url)
            
            if !imageFileName.isEmpty {
                let imageurl = fileURLProvider.makeFileURL(named: imageFileName)
                print("+++++++++++This is a fucking image url: \(imageurl)")
                try FileManager.default.removeItem(at: imageurl)
            }
        } catch (let error) {
            print("delete file from the file manager doesn't work because: \(error)")
        }
    }
    
    #warning("add remove all files")
    func removeAllDiaries() throws(RealmError) {
        let realm = self.realm
        
        do {
            try realm.safeWrite {
                realm.deleteAll()
            }
        } catch {
            throw .failedToRemove
        }
    }
    
    func renameDiary(diary: RecordingFileDetails, to newName: String) throws(RealmError) {
        
        guard let realmInstance = realm.object(ofType: RecordingsDetailsRealmModel.self, forPrimaryKey: diary.id) else {
            throw .failedToRename
        }
        
        do {
            try realm.safeWrite {
                realmInstance.name = newName
            }
        } catch {
            throw .failedToRename
        }
    }
    
    func updateDiary(
        diary: RecordingFileDetails,
        newName: String?,
        newImage: String?,
        newMood: String?,
        newText: String?
    ) throws(RealmError) {
        
        guard let realmInstance = realm.object(ofType: RecordingsDetailsRealmModel.self, forPrimaryKey: diary.id) else {
            throw .failedToUpdate
        }
        print("!!!!", newText)
        do {
            try realm.safeWrite {
                if let newName {
                    realmInstance.name = newName
                }
                if let newImage {
                    realmInstance.imageFileName = newImage
                }
                if let newMood {
                    realmInstance.mood = newMood
                }
                if let newText {
                    realmInstance.text = newText
                }
            }
        } catch {
            throw .failedToUpdate
        }
    }
}

extension RecordingsDetailsRealmManager: ListRecordingHandler {
    //ino mitooni ba result ham benevisi chon ham khorooji dare ham error
    func getAllDiariesList() -> [RecordingFileDetails] {
        let realm = self.realm
        
        return realm
            .objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: false)
            .map {
                let sample = RecordingFileDetails(
                    id: $0.identifier,
                    fileName: $0.fileName,
                    name: $0.name,
                    imageFileName: $0.imageFileName,
                    date: $0.date,
                    duration: $0.duration,
                    mood: $0.mood,
                    text: $0.text
                )
                
                print("this is list of mapppppeeedddd realm data: @@@@@: \(sample)")
                return sample
            }
    }
    
    func getAllDiariesWithPublisher() -> AnyPublisher<[RecordingFileDetails], RealmError> {
        
        let realm = self.realm
        
        let results = realm
            .objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: false)
        
        print("this is list of realm data: %%%%: \(results)")
        
        let subject = PassthroughSubject<[RecordingFileDetails], RealmError>()
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
                                imageFileName: $0.imageFileName,
                                date: $0.date,
                                duration: $0.duration,
                                mood: $0.mood,
                                text: $0.text
                            )
                            print("this is list of mapppppeeedddd realm data: @@@@@: \(sample)")
                            return sample
                        }
                    )
                )
            case .error:
                subject.send(completion: .failure(.failedToGetList))
            }
        }
        tokens.append(token)
        return subject.eraseToAnyPublisher()
    }
    
    func getAllDiariesDataGroupedByDate(startDate: Date, endDate: Date) -> [Date: Int] {
        let calendar = Calendar.current
        
        let realm = self.realm
        
        let results = realm
            .objects(RecordingsDetailsRealmModel.self)
            .where { $0.date >= startDate && $0.date <= endDate }
        
        var grouped: [Date: Int] = [:]
        
        for record in results {
            let dayKey = calendar.startOfDay(for: record.date)
            grouped[dayKey, default: 0] += 1
        }
        
        return grouped
    }
    
    func getNumberOfDiariesInDaysOfOneMonth(date: Date) throws(RealmError) -> [Date: Int] {
        
        let calendar = Calendar.current
        
        let realm = self.realm
        
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
    
    func getNumberOfDiariesInOneDay(date: Date) -> Int {
        let realm = self.realm
        
        let result = realm
            .objects(RecordingsDetailsRealmModel.self)
            .where {$0.date == date}
        
        return result.count
    }
    
    func getDiariesOfOneDay(date: Date) -> [RecordingFileDetails] {
        let tomorrow = date.adding(days: 1).startOfDay()
        let today = date.startOfDay()
        
        let results = realm
            .objects(RecordingsDetailsRealmModel.self)
            .where { $0.date >= today && $0.date < tomorrow }
            .sorted(by: \.date, ascending: false)
            .map {
                let sample = RecordingFileDetails(
                    id: $0.identifier,
                    fileName: $0.fileName,
                    name: $0.name,
                    imageFileName: $0.imageFileName,
                    date: $0.date,
                    duration: $0.duration,
                    mood: $0.mood,
                    text: $0.text
                )
                print("*** this is samples: \(sample)")
                return sample
            }
        return Array(results)
    }
    
    func getOldestDate() -> Date {
        
        let realm = self.realm
        
        let result = realm.objects(RecordingsDetailsRealmModel.self)
            .sorted(by: \.date, ascending: true)
            .first
            .map { $0.date } ?? Date()
        
        return result
    }
}
