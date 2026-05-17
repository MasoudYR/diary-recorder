//
//  RecorderMainPageViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 5/9/26.
//

import Foundation
import Combine
import AVFoundation
import DSWaveformImageViews

class RecorderMainPageViewModel: ObservableObject {
    
    @Published var isRecording = false
    @Published var isFinished = false
    @Published var isPaused = false
    @Published var timeString: String = "00:00:00.00"
    @Published var waveformSamples: [Float] = []
    @Published var currentRecordingURL: URL?

    //private var audioRecorder: AVAudioRecorder?
    let audioRecorderService = AudioRecorderService()
    private var displayLink: CADisplayLink?
    private var startTime: Date?

//    private var audioPlayer: AVAudioPlayer?
//    private let fileManager = FileManager.default
//    private let documentsURL: URL
//    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared

    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        audioRecorderService.$isRecording
            .assign(to: \.isRecording, on: self)
            .store(in: &cancellables)
        
        audioRecorderService.$isFinished
            .assign(to: \.isFinished, on: self)
            .store(in: &cancellables)
        
        audioRecorderService.$isPaused
            .assign(to: \.isPaused, on: self)
            .store(in: &cancellables)
        
        audioRecorderService.$timeString
            .assign(to: \.timeString, on: self)
            .store(in: &cancellables)
        
        audioRecorderService.$waveformSamples
            .assign(to: \.waveformSamples, on: self)
            .store(in: &cancellables)
        
        
    }
    
    func startRecording() {
        audioRecorderService.getAudioPermissionAndStartRecording()
    }
    
    func resumeRecording() {
        audioRecorderService.resumeRecording()
    }
    
    func stopRecording() {
        audioRecorderService.stopRecording()
    }
    
    func pauseRecording() {
        audioRecorderService.pauseRecording()
    }
    
}
