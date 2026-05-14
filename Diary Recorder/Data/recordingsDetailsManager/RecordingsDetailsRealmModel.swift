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
    private(set) var fileURL: String = ""
    
    @Persisted
    var name: String = ""
    
    @Persisted
    private(set) var date: Date = Date()
    
    @Persisted
    private(set) var duration: TimeInterval = 0
    
    convenience init(
        identifier: UUID,
        fileURL: String,
        name: String,
        date: Date,
        duration: TimeInterval
    ) {
        self.init()
        self.identifier = identifier
        self.fileURL = fileURL
        self.name = name
        self.date = date
        self.duration = duration
    }
}

