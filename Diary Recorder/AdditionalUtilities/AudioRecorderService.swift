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
    
    @Published var isRecording = false
    @Published var isFinished = false
    @Published var isPaused = false
    @Published var timeString: String = "00:00:00.00"
    @Published var waveformSamples: [Float] = []
    @Published var recordings: [RecordingFileDetails] = []
    @Published var currentRecordingFileName: String?
    
    private var audioRecorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    
    private var startTime: Date?
    private let fileURLProvider: RecordingDiaryFileURLProvider
    private let fileManager = FileManager.default
    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared
    
    
    init(fileURLProvider: RecordingDiaryFileURLProvider = .default()) {
        self.fileURLProvider = fileURLProvider
        super.init()
        setupAudioSession()
        //try? recordingsDetailsRealmManager.removeAllRecordings()
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
    
    func startRecording(name: String? = nil) {
        //deactiveAudioSession()
        activeAudioSession()
        stopRecording()
        print("@@@@@ Recording func in audiorecorder is running")
        let fileName = "\(UUID().uuidString).m4a"
        let fileURL = fileURLProvider.makeDiaryFileURL(named: fileName)
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
            
            isRecording = true
            isPaused = false
            isFinished = false
            currentRecordingFileName = fileName
            startTime = Date()
            
            waveformSamples = []
            startDisplayLink()
            
            print("Recording started")
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    func pauseRecording() {
        guard let recorder = audioRecorder, isRecording, !isPaused else { return }
        print("@@@@@ Pause recording func in audiorecorder is running")
        recorder.pause()
        isPaused = true
        
        displayLink?.isPaused = true
        print("Recording paused")
    }
    
    func resumeRecording() {
        guard let recorder = audioRecorder, isRecording, isPaused else { return }
        print("@@@@@ Resume recording func in audiorecorder is running")
        recorder.record()
        isPaused = false
        
        displayLink?.isPaused = false
        print("Recording resumed")
    }
    
    func stopRecording() {
        print("@@@@@ Stop recording func in audiorecorder is running")
        audioRecorder?.stop()
        displayLink?.invalidate()
        displayLink = nil
        audioRecorder = nil
        
        isRecording = false
        isFinished = true
        timeString = "00:00:00.00"
        waveformSamples = []
        
        if let fileName = currentRecordingFileName {
            let url = fileURLProvider.makeDiaryFileURL(named: fileName)
            let duration = getAudioDuration(url: url)
            let newRecording = RecordingFileDetails(
                id: UUID(),
                fileName: fileName,
                name: "Recording \(Date().formatted())",
                date: Date(),
                duration: duration
            )
            recordings.insert(newRecording, at: 0)
            saveRecordings(newRecording: newRecording)
            print("📁 File saved at: \(url.path)")
            currentRecordingFileName = nil
        }
    }
    
    private func startDisplayLink() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateTimeAndWaveform))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateTimeAndWaveform() {
        guard let start = startTime,
              let recorder = audioRecorder else { return }
        
        let elapsed = Date().timeIntervalSince(start)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600 / 60)
        let seconds = Int(elapsed) % 60
        let milliseconds = Int((elapsed.truncatingRemainder(dividingBy: 1)) * 100)
        
        timeString = String(format: "%02d:%02d:%02d.%02d", hours, minutes, seconds, milliseconds)

            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            let normalized = max(0, min(1, 1 - pow(10, power / 20)))
            
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.waveformSamples.append(normalized)
            if (self.waveformSamples.count ) > 800 {
                self.waveformSamples.removeFirst(8)
            }
        }
        
    }
    
    private func getAudioDuration(url: URL) -> TimeInterval {
        do {
           let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            print("Error getting duration: \(error)")
            return 0
        }
    }
    
    private func saveRecordings(newRecording: RecordingFileDetails) {
        do {
            try recordingsDetailsRealmManager.saveRecording(newRecording)
        } catch {
            print("Save recording error: \(error)")
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
