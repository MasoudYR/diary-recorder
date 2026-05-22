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
    
    @Published var isPlaying = false
    @Published var isFinished = false
    @Published var isPaused = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var maximumTrackTimeToShow: TimeInterval = 0
    @Published var minimumTrackTimeToShow: TimeInterval = 0
    @Published var currentlyPlayingFileDetails: RecordingFileDetails?
    
    private let fileURLProvider: RecordingDiaryFileURLProvider
    private var player: AVPlayer = AVPlayer()
    private var displayLink: CADisplayLink?
    
    private var subscriptions = Set<AnyCancellable>()
    private var boundryObserver: Any?
    
    
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
        
        print(">>>", Self.self, #function, "fileURL: \(diaryRecorded.fileName)")
        
        let fileURL = fileURLProvider.makeDiaryFileURL(named: diaryRecorded.fileName)
        
        let asset = AVAsset(url: fileURL)
        let playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: [
                .tracks,
                .duration,
                .commonMetadata
            ]
        )
        
        observePlayerItem(playerItem)
        observeFinish(for: playerItem)
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        isPlaying = true
        isFinished = false
        isPaused = false
        currentlyPlayingFileDetails = diaryRecorded
        
        startDisplayLink()
    }
    
    private func observePlayerItem(_ playerItem: AVPlayerItem) {
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    let seconds = playerItem.duration.seconds
                    guard seconds.isFinite, seconds > 0 else { return }
                    self.duration = seconds
                    self.setupBoundryObserver( duration: seconds)
                    print("READY to play - duration: \(seconds)")
                case .failed:
                    print("❌ PlayerItem failed: \(playerItem.error?.localizedDescription ?? "unknown")")
                    self.stop()
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        playerItem.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .sink { isReady in
                print("isPlaybackLikelyToKeepUp: \(isReady)")
            }
            .store(in: &subscriptions)
    }
    
    private func setupBoundryObserver(duration: TimeInterval) {
        removeBoundryObserver()
        
        let triggerTime = max (0, duration - 0.2)
        let coreMediaTime = CMTime(seconds: triggerTime, preferredTimescale: 600)
        
        boundryObserver = player.addBoundaryTimeObserver(
            forTimes: [NSValue(time: coreMediaTime)],
            queue: .main,
            using: { [weak self] in
                guard let self else { return }
                print("🎯 BoundaryObserver fired — 0.2s before end")
                //self.handleFinish()
            }
        )
    }
    
    private func removeBoundryObserver() {
        if let observer = boundryObserver {
            player.removeTimeObserver(observer)
            boundryObserver = nil
        }
    }
    
    private func observeFinish(for playerItem: AVPlayerItem) {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                print("🏁 AVPlayerItemDidPlayToEndTime fired")
                self.handleFinish()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
                print("❌ Failed to play to end: \(error?.localizedDescription ?? "unknown")")
                self?.stop()
            }
            .store(in: &subscriptions)
    }
    
    private func handleFinish() {
        stop()
        isFinished = true
        isPaused = false
    }
    
    func pause() {
        player.pause()
        isPlaying = false
        isPaused = true
        displayLink?.isPaused = true
    }
    
    func resume() {
        guard !isFinished else { return }
        player.play()
        isPlaying = true
        isPaused = false
        displayLink?.isPaused = false
    }
    
    func stop() {
        removeBoundryObserver()
        subscriptions.removeAll()
        
        player.pause()
        player.seek(to: .zero)
        stopDisplayLink()
        
        
        isPlaying = false
        isPaused = false
        currentTime = 0
        
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stop function is callliinnnggggg ")
    }
    
    func seek(to time: TimeInterval) {
        let clamped = max(0, min(time, duration))
        let coreMediaTime = CMTime(seconds: clamped, preferredTimescale: 600)
        player.seek(
            to: coreMediaTime,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
        currentTime = clamped
    }
    
    func seekForward(by seconds: TimeInterval = 5.0) {
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: seconds, preferredTimescale: 600))
         
        let duration = player.currentItem?.duration ?? .zero
        let finalTime = CMTimeMinimum(newTime, duration)
        
        player.seek(to: finalTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
            if finished {
                print("seeked forward \(seconds) seconds")
            }
        }
    }
    
    func seekBackward(by seconds: TimeInterval = 5.0) {
        let currentTime = player.currentTime()
        let targetseconds = currentTime.seconds - seconds
        
        let finalSeconds = max(0, targetseconds)
        
        let targetTime = CMTime(seconds: finalSeconds, preferredTimescale: 600)
        
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] completed in
            guard let self else { return }
            if completed {
                print("seked backward \(seconds) seconds")
                self.updateCurrentTime()
            }
            
        }
        
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
        guard isPlaying else { return }
        
        let time = player.currentTime().seconds
        guard time.isFinite else { return }
        
        currentTime = time
        maximumTrackTimeToShow = time
        minimumTrackTimeToShow = duration - time
        print(">>>>this is currentTime: \(currentTime)")
    }
    
    deinit {
        stop()
    }
    
}
