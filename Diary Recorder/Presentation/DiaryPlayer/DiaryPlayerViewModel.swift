//
//  DiaryPlayerViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/13/26.
//

import Foundation
import Combine
import AVFoundation
import DSWaveformImageViews

class DiaryPlayerViewModel: ObservableObject {
    
    @Published var isPlaying = false
    @Published var isFinished = true
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentlyPlaying: RecordingFileDetails?
    
    private var dateFormatter: DateFormatter
    let audioPlayerService = AudioPlayerService()
    //AudioPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(diary: RecordingFileDetails) {
        audioPlayerService.currentlyPlayingFileDetails = diary
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd HH:mm:ss"
        
        audioPlayerService.$isPLaying
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        
        audioPlayerService.$isFinished
            .assign(to: \.isFinished, on: self)
            .store(in: &cancellables)
        
        audioPlayerService.$currentTime
            .assign(to: \.currentTime, on: self)
            .store(in: &cancellables)
        
        audioPlayerService.$duration
            .assign(to: \.duration, on: self)
            .store(in: &cancellables)
        
        audioPlayerService.$currentlyPlayingFileDetails
            .assign(to: \.currentlyPlaying, on: self)
            .store(in: &cancellables)
    }
    
    func play(_ diaryRecorded: RecordingFileDetails) {
        audioPlayerService.play(diaryRecorded: diaryRecorded)
    }
    
    func pause() {
        audioPlayerService.pause()
    }
    
    func resume() {
        audioPlayerService.resume()
    }
    
    func stop() {
        audioPlayerService.stop()
    }
    
    func seek(to progress: Double) {
        let time = progress * audioPlayerService.duration
        audioPlayerService.seek(to: time)
    }
   
    func changeDateAndTime(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
