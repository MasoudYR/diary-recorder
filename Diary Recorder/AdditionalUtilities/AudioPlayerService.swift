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
    
    @Published var playingStateDescriptor: PlayingStateDescriptor?
   
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
    
    func prepareToPlay(diaryRecorded: RecordingFileDetails) {
        let fileURL = fileURLProvider.makeFileURL(named: diaryRecorded.fileName)
        
        let asset = AVAsset(url: fileURL)
        
        //self.duration = asset.duration.seconds
        self.playingStateDescriptor = PlayingStateDescriptor(
            item: diaryRecorded,
            duration: asset.duration.seconds,
            currentTime: .zero,
            playingState: .idle
        )
    }
    
    func play(diaryRecorded: RecordingFileDetails) {
        
        guard
            let playingStateDescriptor,
            playingStateDescriptor.playingState != .paused else {
            resume()
            return
        }
        
        stop(seekToZero: false)
        
        print(">>>", Self.self, #function, "fileURL: \(diaryRecorded.fileName)")
        
        let fileURL = fileURLProvider.makeFileURL(named: diaryRecorded.fileName)
        
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
        
        //isPlaying = true
        //isFinished = false
        //isPaused = false
        self.playingStateDescriptor = PlayingStateDescriptor(
            item: diaryRecorded,
            duration: asset.duration.seconds,
            currentTime: .zero,
            playingState: .playing
        )
        
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
                    guard let playingStateDescriptor,
                          seconds.isFinite,
                          seconds > 0 else { return }
                    
                    self.playingStateDescriptor = playingStateDescriptor.updated(\.duration, to: seconds)
                    self.setupBoundryObserver( duration: seconds)
                    print("READY to play - duration: \(seconds)")
                case .failed:
                    print("❌ PlayerItem failed: \(playerItem.error?.localizedDescription ?? "unknown")")
                    self.stop(seekToZero: true)
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
//        playerItem.publisher(for: \.isPlaybackLikelyToKeepUp)
//            .receive(on: DispatchQueue.main)
//            .sink { isReady in
//                print("isPlaybackLikelyToKeepUp: \(isReady)")
//            }
//            .store(in: &subscriptions)
    }
    
    private func setupBoundryObserver(duration: TimeInterval) {
        removeBoundryObserver()
        
        let triggerTime = max (0, duration - 0.2)
        let coreMediaTime = CMTime(seconds: triggerTime, preferredTimescale: 600)
        
        boundryObserver = player.addBoundaryTimeObserver(
            forTimes: [NSValue(time: coreMediaTime)],
            queue: .main,
            using: { [weak self] in
                //guard let self else { return }
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
                guard let self else { return }
                let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
                print("❌ Failed to play to end: \(error?.localizedDescription ?? "unknown")")
                stop(seekToZero: true)
            }
            .store(in: &subscriptions)
    }
    
    private func handleFinish() {
        //guard let playingStateDescriptor else { return }
        print("handle finish is calling before stop")
        stop(seekToZero: true)
        print("handle finish is calling after stop")
//        self.playingStateDescriptor = playingStateDescriptor.updated(\.playingState, to: .finished)
    }
    
    func pause() {
        guard
            let playingStateDescriptor,
            let displayLink else { return }
        player.pause()
        self.playingStateDescriptor = playingStateDescriptor.updated(\.playingState, to: .paused)
        
        displayLink.isPaused = true
    }
    
    func resume() {
        guard let playingStateDescriptor,
              playingStateDescriptor.playingState != .finished,
              let displayLink
        else { return }
        player.play()
        
        self.playingStateDescriptor = playingStateDescriptor.updated(\.playingState, to: .playing)
        
        displayLink.isPaused = false
    }
    
    private func stop(seekToZero: Bool) {
        removeBoundryObserver()
        subscriptions.removeAll()
        
        if seekToZero {
            player.pause()
            player.seek(to: .zero)
        }
        stopDisplayLink()
        
        guard let playingStateDescriptor else { return }
        
        // TODO: check 'playingState'
        self.playingStateDescriptor = playingStateDescriptor
            .updated(\.playingState, to: .finished)
            .updated(\.currentTime, to: .zero)
        
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ stop function is callliinnnggggg ")
    }
    
    func stop() {
        stop(seekToZero: true)
    }
    
    func seek(to time: TimeInterval) {
        guard let playingStateDescriptor else { return }
        let duration = playingStateDescriptor.duration
        let clamped = max(0, min(time, duration))
        let coreMediaTime = CMTime(seconds: clamped, preferredTimescale: 600)
        player.seek(
            to: coreMediaTime,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
        self.playingStateDescriptor = playingStateDescriptor.updated(\.currentTime, to: clamped)
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
        displayLink!.preferredFramesPerSecond = 60
        displayLink!.add(to: .main, forMode: .common)
    }
    
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateCurrentTime() {
        guard let playingStateDescriptor,
              playingStateDescriptor.playingState == .playing
        else { return }

        let time = player.currentTime().seconds
        guard time.isFinite else { return }
        
        self.playingStateDescriptor = playingStateDescriptor.updated(\.currentTime, to: time)
        print(">>>>this is currentTime: \(time)")
    }
    
    deinit {
        stop(seekToZero: true)
    }
    
}
