//
//  AudioPlayerService.swift
//  Diary Recorder
//
//  Created by Masoud on 5/14/26.
//

import Foundation
import AVFoundation
import Combine

class AudioPlayerService: NSObject {
    //static let shared = AudioPlayerService()
    
    @Published var isPLaying = false
    @Published var isFinished = false
    @Published var isPaused = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var maximumTrackTimeToShow: TimeInterval = 0
    @Published var minimumTrackTimeToShow: TimeInterval = 0
    @Published var currentlyPlayingFileDetails: RecordingFileDetails?
    
    private let fileURLProvider: RecordingDiaryFileURLProvider
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    init(fileURLProvider: RecordingDiaryFileURLProvider = .default()) {
        self.fileURLProvider = fileURLProvider
        super.init()
        setupAudioSession()
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    func deactiveAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("failed to deactivation of session avaudio")
        }
    }
    
    func play(diaryRecorded: RecordingFileDetails) {
        
        guard !isPaused else {
            resume()
            return
        }
        
        stop()
        
        do {
            print(">>>", Self.self, #function, "fileURL: \(diaryRecorded.fileName)")
            
            let fileURL = fileURLProvider.makeDiaryFileURL(named: diaryRecorded.fileName)
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPLaying = true
            isFinished = false
            isPaused = false
            currentlyPlayingFileDetails = diaryRecorded
            duration = audioPlayer?.duration ?? 0
            
            startDisplayLink()
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPLaying = false
        isPaused = true
        displayLink?.isPaused = true
    }
    
    func resume() {
        //guard !isFinished else { return }
        audioPlayer?.play()
        isPLaying = true
        isPaused = false
        displayLink?.isPaused = false
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        stopDisplayLink()
        
        isPLaying = false
        isPaused = false
        currentTime = 0
        
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stop function is callliinnnggggg ")
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = max(0, min(time, duration))
        currentTime = audioPlayer?.currentTime ?? 0
    }
    
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateCurrentTime))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateCurrentTime() {
        guard let audioPlayer = audioPlayer,
              audioPlayer.isPlaying else { return }
        currentTime = audioPlayer.currentTime
        maximumTrackTimeToShow = duration - currentTime
        minimumTrackTimeToShow = currentTime
        print(">>>>this is currentTime: \(currentTime)")
        
        if (duration - currentTime) < 0.2 {
            DispatchQueue.main.async { [weak self] in
            guard let self else { return }
                self.stop()
                print("didfinish called &&&&&&&&&&&&&&&&")
                self.isFinished = true
                self.isPaused = false
            }
        }
    }
    
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self else { return }
//            self.stop()
//            print("didfinish called &&&&&&&&&&&&&&&&")
//            self.isFinished = true
//            self.isPaused = false
//        }
    }
    
    
}
