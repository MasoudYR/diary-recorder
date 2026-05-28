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
    
    private var isChangingTrack: Bool = false
    private let diaryListDataCollection: [RecordingFileDetails]
    private var diaryIndex: Int
    private var dateFormatter: DateFormatter
    let audioPlayerService = AudioPlayerService()
    //AudioPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(diaryIndex: Int, diaryListDataCollection: [RecordingFileDetails]) {
        self.diaryListDataCollection = diaryListDataCollection
        self.diaryIndex = diaryIndex
        audioPlayerService.currentlyPlayingFileDetails = diaryListDataCollection[diaryIndex]
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        setupBindings()
        
    }
    
    private func setupBindings() {
        
        audioPlayerService.$duration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                guard let self, !isChangingTrack else { return }
                self.duration = duration
                self.updateTrackTimes(current: self.currentTime, duration: duration)
            }
            .store(in: &cancellables)
        
        audioPlayerService.$currentTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentTime in
                guard let self, !isChangingTrack else { return }
                self.currentTime = currentTime
                self.updateTrackTimes(current: currentTime, duration: self.duration)
            }
            .store(in: &cancellables)
        
        audioPlayerService.$isPlaying
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        
        audioPlayerService.$isFinished
            .assign(to: \.isFinished, on: self)
            .store(in: &cancellables)
        
        audioPlayerService.$currentlyPlayingFileDetails
            .assign(to: \.currentlyPlaying, on: self)
            .store(in: &cancellables)
    }
    
    
    
    private func updateTrackTimes(current: TimeInterval, duration: TimeInterval) {
        let remaining = max(0, duration - current)
        minimumTrackTimeString = transformTime(current)
        maximumTrackTimeString = "-" + transformTime(remaining)
    }
    
    private func switchTrack(to index: Int) {
        let diary = diaryListDataCollection[index]
        diaryIndex = index
        
        isChangingTrack = true
        currentTime = 0
        duration = diary.duration
        updateTrackTimes(current: 0, duration: diary.duration)
        audioPlayerService.currentlyPlayingFileDetails = diary
        play(diary)
        isChangingTrack = false
    }
    
    func prepareToPlay() {
        guard let diaryRecorded = audioPlayerService.currentlyPlayingFileDetails else { return }
        audioPlayerService.prepareToPlay(diaryRecorded: diaryRecorded)
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
    
    func playNextDiary() {
        let nextDiaryIndex = diaryIndex + 1
        guard nextDiaryIndex < diaryListDataCollection.count else { return }
        
        switchTrack(to: nextDiaryIndex)
    }
    
    func playPreviousDiary() {
        let previousDiaryIndex = diaryIndex - 1
        guard previousDiaryIndex >= 0 else { return }
        
        switchTrack(to: previousDiaryIndex)
    }
   
    func changeDateAndTime(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func transformTime(_ duration: TimeInterval) -> String {
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
