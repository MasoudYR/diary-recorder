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
    @Published var isFinished = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentlyPlaying: RecordingFileDetails?
    @Published var minimumTrackTimeString: String = "00:00:00"
    @Published var maximumTrackTimeString: String = "00:00:00"
    
    private var dateFormatter: DateFormatter
    let audioPlayerService = AudioPlayerService()
    //AudioPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(diary: RecordingFileDetails) {
        audioPlayerService.currentlyPlayingFileDetails = diary
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        audioPlayerService.$isPlaying
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
        
        audioPlayerService.$minimumTrackTimeToShow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] minimumTrackTime in
                guard let self else { return }
                self.minimumTrackTimeString = changeDuration(minimumTrackTime)
            }
            .store(in: &cancellables)
        
        audioPlayerService.$maximumTrackTimeToShow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] maximumTrackTime in
                guard let self else { return }
                self.maximumTrackTimeString =  "-" + changeDuration(maximumTrackTime)
            }
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
    
    func seekForward(to seconds: TimeInterval = 5) {
        audioPlayerService.seekForward(by: seconds)
    }
    
    func seekBackward(to seconds: TimeInterval = 5) {
        audioPlayerService.seekBackward(by: seconds)
    }
   
    func changeDateAndTime(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func changeDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600 / 60)
        let seconds = Int(duration) % 60
        let milliseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        let timeString = String(
            format: "%02d:%02d:%02d",
            hours,
            minutes,
            seconds,
            milliseconds
        )
        return timeString
    }
}
