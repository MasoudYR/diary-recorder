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
    
    @Published var currentTime: TimeInterval = 0

    var lastSavedDiary: RecordingFileDetails?
    private let recordingsDetailsRealmManager: RecordingModifierHandler
    let audioRecorderService: AudioRecorderService
    private var displayLink: CADisplayLink?
    private var startTime: Date?
    private var dateFormatter: DateFormatter = DateFormatter()
    
    var nameCurrentValueSubject: PassthroughSubject<String, Never> = .init()

    var updateDetailsCurrentValueSubject: PassthroughSubject<UpdateDetails, Never> = .init()
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init(recordingsDetailsRealmManager: RecordingModifierHandler, audioRecorderService: AudioRecorderService) {
        self.recordingsDetailsRealmManager = recordingsDetailsRealmManager
        self.audioRecorderService = audioRecorderService
        binding()
    }

    private func binding() {
        
        nameCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                guard let self else { return }
                self.renameLastDiary(name: name)
            }
            .store(in: &cancellables)
        
        updateDetailsCurrentValueSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] details in
                guard let self else { return }
                updateLastDiaryDetails(
                    newName: details.name,
                    newImage: details.imageFileName,
                    newMood: details.mood,
                    newText: details.text
                )
            }
            .store(in: &cancellables)
    }
    
    func prepareToRecord() {
        audioRecorderService.prepareToRecord()
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
    
    func saveRecording() {
        guard let recordingsStateDescriptor = audioRecorderService.recordingStateDescriptor else { return }
        let url = recordingsStateDescriptor.itemURL
        let fileName = recordingsStateDescriptor.itemName
        let imageFileName = ""
        let date = Date()
        let duration = getAudioDuration(url: url)
        
        let currentRecordingFileDetails = RecordingFileDetails(
            id: UUID(),
            fileName: fileName,
            name: dateToString(date: date),
            imageFileName: imageFileName,
            date: date,
            duration: duration,
            mood: "pokerface",
            text: "",
        )
        
        do {
            try recordingsDetailsRealmManager.saveDiary(diary: currentRecordingFileDetails)
            self.lastSavedDiary = currentRecordingFileDetails
            print("📁 File saved at: \(url.path)")
        } catch {
            print("Save recording error: \(error)")
            if error == .failedToSave {
                //handle showing alert
            }
        }
    }
    
    func renameDiary(diary: RecordingFileDetails,to newName: String) {
        
        do{
            try recordingsDetailsRealmManager.renameDiary(diary: diary, to: newName)
        } catch {
            print("Rename recording Error: \(error)")
        }
    }
    
    
    
    func renameLastDiary(name: String) {
        
        guard let lastSavedDiary else { return }
        
        renameDiary(diary: lastSavedDiary, to: name)
    }
    
    func updateLastDiaryDetails(newName: String, newImage: String, newMood: String, newText: String) {
        guard let lastSavedDiary else { return }
        
        do {
            try recordingsDetailsRealmManager.updateDiary(diary: lastSavedDiary, newName: newName, newImage: newImage, newMood: newMood, newText: newText)
        } catch {
            print("you can no tupdate your diary: \(error)")
            //handle error alert
        }
    }
    
    func transformTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600 / 60)
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        let timeString = String(
            format: "%02d:%02d:%02d.%02d",
            hours,
            minutes,
            seconds,
            milliseconds
        )
        return timeString
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
    
    private func dateToString(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        let text = "Diary \(formattedDate)"
        return text
    }
    
}


struct UpdateDetails {
    let name: String
    let imageFileName: String
    let mood: String
    let text: String
}
