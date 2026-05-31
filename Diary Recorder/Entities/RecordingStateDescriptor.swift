//
//  RecordingStateDescriptor.swift
//  Diary Recorder
//
//  Created by Masoud on 5/31/26.
//

import Foundation

struct RecordingStateDescriptor: Equatable, Hashable {
    var itemURL: URL
    var itemName: String
    var currentTime: TimeInterval
    var recordingState: RecordingState
}

extension RecordingStateDescriptor {
    mutating func update<V>(_ keyPath: WritableKeyPath<Self, V>, to value: V) {
        self[keyPath: keyPath] = value
    }
    
    func updated<V>(_ keyPath: WritableKeyPath<Self, V>, to value: V) -> Self {
        var copy = self
        copy.update(keyPath, to: value)
        return copy
    }
}

enum RecordingState: Equatable, Hashable {
    case idle
    case recording
    case paused
    case finished
}
