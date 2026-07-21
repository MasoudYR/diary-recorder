//
//  DiaryCustomizerViewModel.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import Combine

class DiaryCustomizerViewModel {
    
    @Published var selectedEmoji: EmojiType?
    @Published var selectedImage: UIImage?
    @Published var textDiary: String?
    @Published private(set) var textDiaryCount: String = ""
    
    private let fileURLProvider: RecordingDiaryFileURLProvider = .default()
    var isDefaultImage: Bool = true
    var diary: RecordingFileDetails
    private var updateDetailsCurrentValueSubject: PassthroughSubject<UpdateDetails, Never>
    var nameDiary: String?
    var selectedImageURLString: String = ""
    var selectedEmojiString: String = ""
    //var textDiary: String = ""
    
    var emojiArray: [EmojiModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(diary: RecordingFileDetails ,updateDetailsCurrentValueSubject: PassthroughSubject<UpdateDetails, Never>) {
        self.diary = diary
        self.updateDetailsCurrentValueSubject = updateDetailsCurrentValueSubject
        setupArrayEmoji()
        toSetInitialValues()
        binding()
    }
    
    private func binding() {
        $textDiary
            .compactMap { $0 }
            .sink { [unowned self] text in
                self.textDiaryCount = "\(text.count)/\(150)"
            }
            .store(in: &cancellables)
    }
    
    private func setupArrayEmoji() {
        emojiArray = [
            EmojiModel(
                grayscaleImage: UIImage(resource: .sunnysmile),
                colorImage: UIImage(resource: .colorsunnysmile),
                type: .sunnysmile
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .grin),
                colorImage: UIImage(resource: .colorgrin),
                type: .grin
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .biggrin),
                colorImage: UIImage(resource: .colorbiggrin),
                type: .biggrin
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .lol),
                colorImage: UIImage(resource: .colorlol),
                type: .lol
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .cuty),
                colorImage: UIImage(resource: .colorcuty),
                type: .cuty
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .bleh),
                colorImage: UIImage(resource: .colorbleh),
                type: .bleh
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .sillydead),
                colorImage: UIImage(resource: .colorsillydead),
                type: .sillydead
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .hearteye),
                colorImage: UIImage(resource: .colorhearteye),
                type: .hearteye
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .kissy),
                colorImage: UIImage(resource: .colorkissy),
                type: .kissy
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .pokerface),
                colorImage: UIImage(resource: .colorpokerface),
                type: .pokerface
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .eyeroll),
                colorImage: UIImage(resource: .coloreyeroll),
                type: .eyeroll
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .sideeye),
                colorImage: UIImage(resource: .colorsideeye),
                type: .sideeye
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .bluemode),
                colorImage: UIImage(resource: .colorbluemode),
                type: .bluemode
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .cry),
                colorImage: UIImage(resource: .colorcry),
                type: .cry
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .wowface),
                colorImage: UIImage(resource: .colorwowface),
                type: .wowface
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .frustrated),
                colorImage: UIImage(resource: .colorfrustrated),
                type: .frustrated
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .ragemode),
                colorImage: UIImage(resource: .colorragemode),
                type: .ragemode
            ),
        ]
    }
    
    func toSetInitialValues() {
        self.nameDiary = diary.name
        self.textDiary = diary.text
        
        
        if !diary.mood.isEmpty {
            self.selectedEmoji = EmojiType(rawValue: diary.mood)
        } else {
            self.selectedEmoji = EmojiType(rawValue: "pokerface")
            print("your selected emoji is empty")
        }
        
        guard !diary.imageFileName.isEmpty else {
            self.selectedImage = UIImage(resource: .placeholderimage)
            self.isDefaultImage = true
            return
        }
        
        let imageURL = fileURLProvider.makeFileURL(named: diary.imageFileName)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                let data = try Data(contentsOf: imageURL)
                if let image = UIImage(data: data) {
                    self.selectedImage = image
                    self.isDefaultImage = false
                }
            } catch {
                print("The image data could not be read: \(error)")
            }
        } else {
            print("image file not exist.")
            self.selectedImage = UIImage(resource: .placeholderimage)
            self.isDefaultImage = true
        }
    }
    
    func updateDiaryDetails() {
        
        if let nameDiary, nameDiary.isEmpty {
            self.nameDiary = diary.name
        }
        
        if let selectedImage,
           !isDefaultImage,
           let data = selectedImage.jpegData(compressionQuality: 1) {
            let imageFileName = "\(UUID().uuidString).jpeg"
            let imageURL = fileURLProvider.makeFileURL(named: imageFileName)
            
            do {
                try data.write(to: imageURL)
                print("image saved successfully: \(imageURL)")
                self.selectedImageURLString = imageFileName
            } catch {
                print("Error saving image: \(error)")
            }
        } else {
            self.selectedImageURLString = ""
        }
        
        if let selectedEmoji {
            selectedEmojiString = selectedEmoji.rawValue
        } else {
            selectedEmojiString = "pokerface"
        }
        
        let newDetails = UpdateDetails(
            name: nameDiary ?? diary.name,
            imageFileName: selectedImageURLString,
            mood: selectedEmojiString,
            text: textDiary ?? ""
        )
        
        updateDetailsCurrentValueSubject.send(newDetails)
        
    }
}
