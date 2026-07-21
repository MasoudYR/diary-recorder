//
//  RecordingFileDetails.swift
//  Diary Recorder
//
//  Created by Masoud on 5/10/26.
//

import Foundation

struct RecordingFileDetails: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let fileName: String
    let name: String
    let imageFileName: String
    let date: Date
    let duration: TimeInterval
    let mood: String
    let text: String
}
