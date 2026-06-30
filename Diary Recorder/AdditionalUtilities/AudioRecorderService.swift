//
//  AudioRecorderService.swift
//  Diary Recorder
//
//  Created by Masoud on 5/16/26.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorderService: NSObject, AVAudioRecorderDelegate {
    
    @Published var recordingStateDescriptor: RecordingStateDescriptor?
    @Published var latestSample: Float = 0
    @Published var recordings: [RecordingFileDetails] = []
    @Published var currentRecordingFileName: String?
    
    private var audioRecorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    private let fileURLProvider: RecordingDiaryFileURLProvider
    private let fileManager = FileManager.default
    
    init(fileURLProvider: RecordingDiaryFileURLProvider = .default()) {
        self.fileURLProvider = fileURLProvider
        super.init()
        setupAudioSession()
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("failed to setup audio session: \(error)")
        }
    }
    
    private func activeAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setActive(true)
            print("activation audio session is successfully")
        } catch {
            print("we can not active audio session again and record your voice")
        }
    }
    
    private func deactiveAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func getAudioPermissionAndStartRecording() {
        let session = AVAudioSession.sharedInstance()
        
        switch session.recordPermission {
        case .undetermined:
            session.requestRecordPermission { [unowned self] granted in
                if granted {
                    startRecording()
                } else {
                    print("please give me audio recording permission")
                }
            }
        case .denied:
            print("please go to settings and give me audio recording permission")
        case .granted:
            startRecording()
        @unknown default:
            fatalError(" give permission MthrFck")
        }
    }
    
    func prepareToRecord() {
        activeAudioSession()
        let fileName = "\(UUID().uuidString).m4a"
        let fileURL = fileURLProvider.makeDiaryFileURL(named: fileName)
        self.recordingStateDescriptor = RecordingStateDescriptor(
            itemURL: fileURL,
            itemName: fileName,
            currentTime: .zero,
            recordingState: .idle
        )
    }
    
    func startRecording(name: String? = nil) {
        prepareToRecord()
        
        stopRecording()
    
        let fileURL = recordingStateDescriptor!.itemURL
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            self.recordingStateDescriptor!.update(\.recordingState, to: .recording)

            startDisplayLink()
            
            print("Recording started")
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    func pauseRecording() {
        guard let recorder = audioRecorder else { return }
        print("@@@@@ Pause recording func in audiorecorder is running")
        
        recorder.pause()
        
        self.recordingStateDescriptor?.update(\.recordingState, to: .paused)
        
        displayLink?.isPaused = true
        print("Recording paused")
    }
    
    func resumeRecording() {
        guard let recorder = audioRecorder else { return }
        print("@@@@@ Resume recording func in audiorecorder is running")
        
        recorder.record()
        
        self.recordingStateDescriptor?.update(\.recordingState, to: .recording)
        
        displayLink?.isPaused = false
        print("Recording resumed")
    }
    
    func stopRecording() {
        print("@@@@@ Stop recording func in audiorecorder is running")
        audioRecorder?.stop()
        displayLink?.invalidate()
        displayLink = nil
        audioRecorder = nil
        
        guard let recordingStateDescriptor else { return }
        
        self.recordingStateDescriptor = recordingStateDescriptor
            .updated(\.recordingState, to: .finished)
            .updated(\.currentTime, to: .zero)
    }
    
    private func startDisplayLink() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateTimeAndWaveform))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateTimeAndWaveform() {
        guard let recorder = audioRecorder,
        let recordingStateDescriptor,
            recordingStateDescriptor.recordingState == .recording
        else { return }
        let time = recorder.currentTime

        self.recordingStateDescriptor?.update(\.currentTime, to: time)

        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        let normalized = max(0, min(1, 1 - pow(10, power / 20)))
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.latestSample = normalized
        }
    }
    
    private func listRecordings() {
        do {
            let folder = fileURLProvider.makeDiaryFileURL(named: "temp.temp").deletingLastPathComponent()
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            print("Saved recordings:", files.map { $0.lastPathComponent })
        } catch {
            print(error)
        }
    }
    
    
}

extension AudioRecorderService {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            listRecordings()
        }
}
