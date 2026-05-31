//
//  PlayingStateDescriptor.swift
//  Diary Recorder
//
//  Created by Masoud on 5/31/26.
//

import Foundation

struct PlayingStateDescriptor: Equatable, Hashable {
    var item: RecordingFileDetails
    var duration: TimeInterval
    var currentTime: TimeInterval
    var playingState: PlayingState
}

extension PlayingStateDescriptor {
    
    mutating func update<V>(_ keyPath: WritableKeyPath<Self, V>, to value: V) {
        self[keyPath: keyPath] = value
    }
    
    func updated<V>(_ keyPath: WritableKeyPath<Self, V>, to value: V) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}

enum PlayingState: Equatable, Hashable {
    case idle
    case playing
    case paused
    case finished
}
