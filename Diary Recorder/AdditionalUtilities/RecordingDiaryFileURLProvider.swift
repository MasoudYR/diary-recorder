//
//  RecordingDiaryFileURLProvider.swift
//  Diary Recorder
//
//  Created by Masoud on 5/17/26.
//

import Foundation

protocol RecordingDiaryFileURLProvider {
    func makeDiaryFileURL(named: String) -> URL
}

struct DefaultRecordingDiaryFileURLProvider: RecordingDiaryFileURLProvider {
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func makeDiaryFileURL(named fileName: String) -> URL {
        baseURL.appendingPathComponent(fileName)
    }
}

extension RecordingDiaryFileURLProvider where Self == DefaultRecordingDiaryFileURLProvider {
    static func `default`(baseURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) -> Self {
        Self(baseURL: baseURL)
    }
}
