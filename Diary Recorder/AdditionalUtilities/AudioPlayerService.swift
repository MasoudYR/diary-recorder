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
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentlyPlayingFileDetails: RecordingFileDetails?
    
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    func play(diaryRecorded: RecordingFileDetails) {
        stop()
        
        do {
            print(">>>", Self.self, #function, "fileURL: \(diaryRecorded.fileURL)")
            let b = try diaryRecorded.fileURL.checkResourceIsReachable()
            print(">>>", Self.self, #function, "checkResourceIsReachable: \(b)")
            audioPlayer = try AVAudioPlayer(contentsOf: diaryRecorded.fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPLaying = true
            isFinished = false
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
        displayLink?.isPaused = true
        let pauseTime = currentTime
        
    }
    
    func resume() {
        audioPlayer?.play()
        isPLaying = true
        displayLink?.isPaused = false
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        stopDisplayLink()
        
        isPLaying = false
        currentTime = 0
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
    }
    
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.stop()
            print("didfinish called &&&&&&&&&&&&&&&&")
            self.isFinished = true
        }
    }
}
