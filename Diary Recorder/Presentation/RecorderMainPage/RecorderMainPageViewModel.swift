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
    @Published var lastSavedDiary: RecordingFileDetails?

    //private var audioRecorder: AVAudioRecorder?
    let audioRecorderService = AudioRecorderService()
    private var displayLink: CADisplayLink?
    private var startTime: Date?
    
    var nameCurrentValueSubject: PassthroughSubject<String, Never> = .init()

    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        binding()
    }
    
    private func binding() {
        
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
        
        audioRecorderService.$lastSavedRecording
            .assign(to: \.lastSavedDiary, on: self)
            .store(in: &cancellables)
        
        nameCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                guard let self else { return }
                self.renameRecording(name: name)
            }
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
    
    func renameRecording(name: String) {
        guard let recording = audioRecorderService.lastSavedRecording else { return }
        audioRecorderService.renameRecording(recording: recording, to: name)
    }
    
}
