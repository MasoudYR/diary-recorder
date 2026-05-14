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

class RecorderMainPageViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    @Published var isRecording = false
    @Published var timeString: String = "00:00:00.00"
    @Published var waveformSamples: [Float] = []
//    @Published var isPlaying = false
//    @Published var isPaused = false
    @Published var recordings: [RecordingFileDetails] = []
    @Published var currentRecordingURL: URL?
//    @Published var currentPlayingURL: URL?
//    @Published var recordingDuration: TimeInterval = 0
//    @Published var playingDuration: TimeInterval = 0
//    @Published var timer: Timer?

    private var audioRecorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    private var startTime: Date?

//    private var audioPlayer: AVAudioPlayer?
    private let fileManager = FileManager.default
    private let documentsURL: URL
    private let recordingsDetailsRealmManager = RecordingsDetailsRealmManager.shared


    
    
    override init() {
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(">>>", "'\(documentsURL)'")
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
            //show message alert we can not record message
        }
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
    
    func startRecording() {
        let fileName = "\(UUID().uuidString).m4a" /* inja dare rename mikone file ro babdn dorostesh kon*/
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        //let waveFormView = WaveformLiveView()
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.updateMeters()
            audioRecorder?.record()
            
            isRecording = true
            currentRecordingURL = fileURL
            startTime = Date()
            waveformSamples = []
            startDisplayLink()
            
            print("Recording started")
        } catch {
            print("Recording failed: \(error)")
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
            if (self.waveformSamples.count ) > 1000 {
                self.waveformSamples.removeFirst(10)
            }
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        displayLink?.invalidate()
        displayLink = nil
        audioRecorder = nil
        
        isRecording = false
        timeString = "00:00:00.00"
        waveformSamples = []
        
        if let url = currentRecordingURL {
            let duration = getAudioDuration(url: url)
            let newRecording = RecordingFileDetails(
                id: UUID(),
                fileURL: url,
                name: "Recording \(Date().formatted())",
                date: Date(),
                duration: duration
            )
            recordings.insert(newRecording, at: 0)
            saveRecordings(newRecording: newRecording)
            print("📁 File saved at: \(url.path)")
        }
    }
    
//    private func startTimer() {
//        recordingDuration = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            guard let self else { return }
//            recordingDuration += 0.1
//            //audioRecorder?.updateMeters()
//            // You can read averagePower for waveform here
//        }
//    }
    
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
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("Saved recordings:", files.map { $0.lastPathComponent })
        } catch {
            print(error)
        }
    }
    
}

extension RecorderMainPageViewModel {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            listRecordings()
        }
}
