//
//  RecordingFileDetails.swift
//  Diary Recorder
//
//  Created by Masoud on 5/10/26.
//

import Foundation

struct RecordingFileDetails: Identifiable, Codable {
    let id: UUID
    let fileURL: URL
    let name: String
    let date: Date
    let duration: TimeInterval
}
