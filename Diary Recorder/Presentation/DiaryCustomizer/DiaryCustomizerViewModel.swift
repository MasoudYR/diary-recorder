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
                grayscaleImage: UIImage(resource: .graysunnysmile),
                colorImage: UIImage(resource: .sunnysmile),
                type: .sunnysmile
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graygrin),
                colorImage: UIImage(resource: .grin),
                type: .grin
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graybiggrin),
                colorImage: UIImage(resource: .biggrin),
                type: .biggrin
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graylol),
                colorImage: UIImage(resource: .lol),
                type: .lol
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graycuty),
                colorImage: UIImage(resource: .cuty),
                type: .cuty
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graybleh),
                colorImage: UIImage(resource: .bleh),
                type: .bleh
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graysillydead),
                colorImage: UIImage(resource: .sillydead),
                type: .sillydead
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .grayhearteye),
                colorImage: UIImage(resource: .hearteye),
                type: .hearteye
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graykissy),
                colorImage: UIImage(resource: .kissy),
                type: .kissy
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graypokerface),
                colorImage: UIImage(resource: .pokerface),
                type: .pokerface
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .grayeyeroll),
                colorImage: UIImage(resource: .eyeroll),
                type: .eyeroll
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graysideeye),
                colorImage: UIImage(resource: .sideeye),
                type: .sideeye
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graybluemode),
                colorImage: UIImage(resource: .bluemode),
                type: .bluemode
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graycry),
                colorImage: UIImage(resource: .cry),
                type: .cry
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .graywowface),
                colorImage: UIImage(resource: .wowface),
                type: .wowface
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .grayfrustrated),
                colorImage: UIImage(resource: .frustrated),
                type: .frustrated
            ),
            EmojiModel(
                grayscaleImage: UIImage(resource: .grayragemode),
                colorImage: UIImage(resource: .ragemode),
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
