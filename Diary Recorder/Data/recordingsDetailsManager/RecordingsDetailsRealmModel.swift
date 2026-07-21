//
//  RecordingsDetailsRealmModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/11/26.
//

import Foundation
import RealmSwift

final class RecordingsDetailsRealmModel: Object {
    
    @Persisted(primaryKey: true)
    private(set) var identifier: UUID = UUID()
    
    @Persisted
    private(set) var fileName: String = ""
    
    @Persisted
    var name: String = ""
    
    @Persisted
    var imageFileName: String = ""
    
    @Persisted
    private(set) var date: Date = Date()
    
    @Persisted
    private(set) var duration: TimeInterval = 0
    
    @Persisted
    var mood: String
    
    @Persisted
    var text: String
    
    convenience init(
        identifier: UUID,
        fileName: String,
        name: String,
        imageFileName: String,
        date: Date,
        duration: TimeInterval,
        mood: String,
        text: String
    ) {
        self.init()
        self.identifier = identifier
        self.fileName = fileName
        self.name = name
        self.imageFileName = imageFileName
        self.date = date
        self.duration = duration
        self.mood = mood
        self.text = text
    }
}

