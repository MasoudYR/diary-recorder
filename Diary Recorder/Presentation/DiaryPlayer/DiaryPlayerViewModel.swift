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
import UIKit

class DiaryPlayerViewModel: ObservableObject {
    
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentlyPlaying: RecordingFileDetails
    @Published var minimumTrackTimeString: String = "00:00:00"
    @Published var maximumTrackTimeString: String = "00:00:00"
    
    private let fileURLProvider: RecordingDiaryFileURLProvider = .default()
    private var isChangingTrack: Bool = false
    private let diaryListDataCollection: [RecordingFileDetails]
    private var diaryIndex: Int
    private var dateFormatter: DateFormatter
    let audioPlayerService = AudioPlayerService()
    private var cancellables = Set<AnyCancellable>()
    
    init(diaryIndex: Int, diaryListDataCollection: [RecordingFileDetails]) {
        self.diaryListDataCollection = diaryListDataCollection
        self.diaryIndex = diaryIndex
        audioPlayerService.playingStateDescriptor = PlayingStateDescriptor(
            item: diaryListDataCollection[diaryIndex],
            duration: diaryListDataCollection[diaryIndex].duration,
            currentTime: .zero,
            playingState: .idle
        )
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.currentlyPlaying = diaryListDataCollection[diaryIndex]
        setupBindings()
    }
    
    private func setupBindings() {
        
        audioPlayerService
            .$playingStateDescriptor
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self, !isChangingTrack else { return }
                
                let newDuration = item.duration
                let newCurrentTime = item.currentTime
                
                self.currentTime = newCurrentTime
                self.duration = newDuration
                
                self.updateTrackTimes(current: newCurrentTime, duration: newDuration)
                self.currentlyPlaying = item.item
            }
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
        
        audioPlayerService.playingStateDescriptor = PlayingStateDescriptor(
            item: diary,
            duration: diary.duration,
            currentTime: .zero,
            playingState: .idle
        )
        play(diary)
        isChangingTrack = false
    }
    
    func prepareToPlay() {
        guard let diaryRecorded = audioPlayerService.playingStateDescriptor?.item else { return }
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
        precondition((0 ... 1).contains(progress), "kossssskesh in chie?...")
        
        guard let duration = audioPlayerService
            .playingStateDescriptor?
            .item
            .duration
        else { return }
        
        let time = progress * duration
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
    
    func getImageOfDiary(diary: RecordingFileDetails) -> UIImage {
        let defaultImage = UIImage(resource: .placeholderimage)
        if !diary.imageFileName.isEmpty {
            let imageURL = fileURLProvider.makeFileURL(named: diary.imageFileName)
            guard FileManager.default.fileExists(atPath: imageURL.path) else {
                print("Image file doesn't exist")
                return defaultImage
            }
            
            do {
                let data = try Data(contentsOf: imageURL)
                if let image = UIImage(data: data) {
                    return image
                } else {
                    return defaultImage
                }
            } catch {
                print("We cannot make image of diary by data")
                return defaultImage
            }
        } else {
            print("Diary has no image.")
            return defaultImage
        }
    }
    
    func getEmojiOfDiary(diary: RecordingFileDetails) -> UIImage {
        //let emoji = EmojiType(rawValue: diary.mood)
        if let emojiImage = UIImage(named: diary.mood) {
            return emojiImage
        } else {
            return UIImage(resource: .pokerface)
        }
    }
}
