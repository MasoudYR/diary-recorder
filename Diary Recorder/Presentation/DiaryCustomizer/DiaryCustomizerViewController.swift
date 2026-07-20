//
//  DiaryCustomizerViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 7/11/26.
//

import Foundation
import UIKit
import Combine
import AVFoundation
import PhotosUI
import TOCropViewController

class DiaryCustomizerViewController: UIViewController, PHPickerViewControllerDelegate {
    
    private let viewModel: DiaryCustomizerViewModel
    private let router: DiaryCustomizerRouter
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let vStackView = UIStackView()
    
    private let parentImagePickerView = UIView()
    private let imagePickerButton = ImagePickerButton()
    
    private let renameParentView = UIView()
    private let renameTitleLabel = UILabel()
    private let renameTextFieldView = UIView()
    private let renameTextField = UITextField()
    
    private let emojiParentView = UIView()
    private let emojiTitleLabel = UILabel()
    private let emojiHCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let diaryTextParentView = UIView()
    private let diaryTextTitleLabel = UILabel()
    private let diaryTextViewView = UIView()
    private let diaryTextView = UITextView()
    private let diaryTextCountLabel = UILabel()
    private let diaryTextPlaceHolder = UILabel()
    
    let imagePicker = UIImagePickerController()
    
    private var isDefaultImage: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellables = Set<AnyCancellable>()
    
    init(viewModel: DiaryCustomizerViewModel, router: DiaryCustomizerRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.diaryCustomizerViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main
        setupUI()
    }
    
    static func make() -> DiaryCustomizerViewController {
        let viewModel = DiaryCustomizerViewModel()
        let router = DiaryCustomizerRouter()
        let viewController = DiaryCustomizerViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    private func setupUI() {
        setupScrollView()
        setupContentView()
        setupVStackView()
        setupImagePickerButton()
        setupRenameView()
        setupEmojiView()
        setupDiaryTextView()
        bindingViewModel()
        actions()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.bounces = false
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(view)
        }
    }
    
    private func setupVStackView() {
        vStackView.axis = .vertical
        vStackView.spacing = 10
        vStackView.distribution = .fill
        vStackView.alignment = .fill
        vStackView.isLayoutMarginsRelativeArrangement = true
        vStackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        contentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupImagePickerButton() {
    
        imagePickerButton.configue(image: nil, photoState: .placeholder)
        
        parentImagePickerView.addSubview(imagePickerButton)
        
        imagePickerButton.snp.makeConstraints { make in
            make.size.equalTo(300)
            make.verticalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(parentImagePickerView)
    }
    
    private func setupRenameView() {
        
        renameTitleLabel.text = "Name diary:"
        renameTitleLabel.textColor = .label
        renameTitleLabel.font = .roundedFont(ofSize: 20, weight: .semibold)
        renameTitleLabel.textAlignment = .left
        
        renameParentView.addSubview(renameTitleLabel)
        
        renameTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(5)
        }
        
        renameTextFieldView.backgroundColor = .systemBackground
        renameTextFieldView.layer.cornerRadius = 20
        
        renameParentView.addSubview(renameTextFieldView)
        
        renameTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(renameTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        
        renameTextField.delegate = self
        renameTextField.text = viewModel.nameDiary
        renameTextField.placeholder = "Maximum 50 characters"
        renameTextField.font = .roundedFont(ofSize: 18, weight: .regular)
        renameTextField.textColor = .label
        renameTextField.backgroundColor = .systemBackground
        
        renameTextFieldView.addSubview(renameTextField)
        
        renameTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview().inset(15)
        }
        
        vStackView.addArrangedSubview(renameParentView)
    }
    
    private func setupEmojiView() {
        emojiTitleLabel.text = "Select mood:"
        emojiTitleLabel.textColor = .label
        emojiTitleLabel.font = .roundedFont(ofSize: 20, weight: .semibold)
        emojiTitleLabel.textAlignment = .left
        
        emojiParentView.addSubview(emojiTitleLabel)
        
        emojiTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(5)
        }
        
        setupEmojiHCollectionView()
        
        vStackView.addArrangedSubview(emojiParentView)
    }
    
    private func setupEmojiHCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        emojiHCollectionView.collectionViewLayout = layout
        emojiHCollectionView.backgroundColor = .systemBackground
        emojiHCollectionView.showsHorizontalScrollIndicator = false
        emojiHCollectionView.layer.cornerRadius = 20
        emojiHCollectionView.layer.masksToBounds = true
        emojiHCollectionView.delegate = self
        emojiHCollectionView.dataSource = self
        emojiHCollectionView.register(EmojiHCollectionCell.self, forCellWithReuseIdentifier: EmojiHCollectionCell.identifier)
    
        emojiParentView.addSubview(emojiHCollectionView)
        
        emojiHCollectionView.snp.makeConstraints { make in
            make.top.equalTo(emojiTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(60)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupDiaryTextView() {
        diaryTextTitleLabel.text = "Write story:"
        diaryTextTitleLabel.font = .roundedFont(ofSize: 20, weight: .semibold)
        diaryTextTitleLabel.textColor = .label
        diaryTextTitleLabel.textAlignment = .left
        
        diaryTextParentView.addSubview(diaryTextTitleLabel)
        
        diaryTextTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(5)
        }
        
        diaryTextViewView.backgroundColor = .systemBackground
        diaryTextViewView.layer.cornerRadius = 20
        
        diaryTextParentView.addSubview(diaryTextViewView)
        
        diaryTextViewView.snp.makeConstraints { make in
            make.top.equalTo(diaryTextTitleLabel.snp.bottom).offset(10)
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(120)
        }
        
        diaryTextView.delegate = self
        diaryTextView.font = .roundedFont(ofSize: 18, weight: .regular)
        diaryTextView.textColor = .label
        diaryTextView.textAlignment = .left
        diaryTextView.backgroundColor = .systemBackground
        diaryTextView.inputAccessoryView = InputAccessoryView(responder: diaryTextView)
        
        diaryTextViewView.addSubview(diaryTextView)
        
        diaryTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.verticalEdges.equalToSuperview().inset(15)
        }
        
        diaryTextCountLabel.text = "\(0)/\(150)"
        diaryTextCountLabel.textColor = .label
        diaryTextCountLabel.font = UIFont.boldSystemFont(ofSize: 10)
        diaryTextCountLabel.textAlignment = .right
        
        diaryTextViewView.addSubview(diaryTextCountLabel)
        
        diaryTextCountLabel.snp.makeConstraints { make in
            make.right.equalTo(diaryTextViewView).inset(15)
            make.bottom.equalTo(diaryTextViewView).inset(5)
        }
        
        diaryTextPlaceHolder.text = """
        Tell the story of your day,
        A moment worth remembering...
        """
        diaryTextPlaceHolder.textColor = .lightGray
        diaryTextPlaceHolder.font = .roundedFont(ofSize: 15, weight: .regular)
        diaryTextPlaceHolder.textAlignment = .center
        diaryTextPlaceHolder.numberOfLines = 0
        diaryTextPlaceHolder.isHidden = !diaryTextView.text.isEmpty
        
        diaryTextViewView.addSubview(diaryTextPlaceHolder)
        
        diaryTextPlaceHolder.snp.makeConstraints { make in
            make.centerX.equalTo(diaryTextView)
            make.top.equalToSuperview().inset(15)
            make.horizontalEdges.equalToSuperview()
        }
        
        vStackView.addArrangedSubview(diaryTextParentView)
    }
    
    private func actions() {
        let imagePickerButtonActionId = UIAction.Identifier("imagePickerButtonActionId")
        let imagePickerButtonAction = UIAction(identifier: imagePickerButtonActionId) { [weak self] _ in
            print("picker action tapped...")
            guard let self else { return }
            self.router.navigateToEditPhotoViewController(isDefaultImage: isDefaultImage)
        }
        
        imagePickerButton.removeAction(identifiedBy: imagePickerButtonActionId, for: .touchUpInside)
        imagePickerButton.addAction(imagePickerButtonAction, for: .touchUpInside)
        
        let renameTextFieldActionId = UIAction.Identifier("renameTextFieldActionId")
        let renameTextFieldAction = UIAction { [weak self] _ in
            guard let self else { return }
            viewModel.nameDiary = renameTextField.text ?? ""
        }
        
        renameTextField.removeAction(identifiedBy: renameTextFieldActionId, for: .editingChanged)
        renameTextField.addAction(renameTextFieldAction, for: .editingChanged)
    }
    
    private func bindingViewModel(){
        viewModel.$selectedEmoji
            .compactMap{ $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPath in
                guard let self else { return }
                emojiHCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedImage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self else { return }
                imagePickerButton.configue(image: image, photoState: .setImage)
            }
            .store(in: &cancellables)
        
        viewModel.$textDiaryCount
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                self.diaryTextCountLabel.text = text
            }
            .store(in: &cancellables)
    }
}

extension DiaryCustomizerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.emojiArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiHCollectionCell.identifier, for: indexPath) as! EmojiHCollectionCell
        if indexPath == viewModel.selectedEmoji {
            cell.configue(image: viewModel.emojiArray[indexPath.row].colorImage)
        } else {
            cell.configue(image: viewModel.emojiArray[indexPath.row].grayscaleImage)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item: \(viewModel.emojiArray[indexPath.row])")
        viewModel.selectedEmoji = indexPath
    }
}


extension DiaryCustomizerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        router.navigateToPickImageByCamera(picker: imagePicker)
    }
    
    func handleCameraSelection() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else  {
            router.navigateToShowAlert(title: "Camera Unavailable", message: "The camera is not available on this device.")
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                DispatchQueue.main.async {
                    if granted {
                        self.presentImagePicker(sourceType: .camera)
                    } else {
                        self.router.navigateToShowAlert(title: "Camera Permission Error", message: "Diary Recorder needs camera access to take photos. Please go to Settings to enable it.")
                    }
                }
            }
        case .authorized:
            presentImagePicker(sourceType: .camera)
        
        case .denied, .restricted:
            router.navigateToShowAlert(title: "Camera Permission Error", message: "Diary Recorder needs camera access to take photos. Please go to Settings to enable it.")
        @unknown default:
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        
        guard  let originalImage = info[.originalImage] as? UIImage  else { return }
        
        dismiss(animated: true) { [unowned self] in
            router.navigateToImageCropViewController(image: originalImage)
        }
        
        print("We took pic successfully. \(viewModel.selectedImage)")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
}

extension DiaryCustomizerViewController {
    func handleGalleryWithPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        router.navigateToSelectImageGallery(picker: phPicker)
    }
    
    func handleGallerySelection() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            router.navigateToShowAlert(title: "Gallery Unavailable", message: "The gallery is not available on this device.")
            return
        }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                guard let self else { return }
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.handleGalleryWithPHPicker()
                    } else {
                        self.router.navigateToShowAlert(title: "Gallery Permission Error", message: "Diary Recorder needs gallery access to select photos. Please go to Settings to enable it.")
                    }
                }
            }
        case .authorized, .limited:
            self.handleGalleryWithPHPicker()
            
        case .denied, .restricted:
            router.navigateToShowAlert(title: "Gallery Permission Error", message: "Diary Recorder needs gallery access to select photos. Please go to Settings to enable it.")
            
        @unknown default:
            break
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self)
        else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self.dismiss(animated: true) {
                        self.router.navigateToImageCropViewController(image: image)
                    }
                    print("We select pic successfully. \(self.viewModel.selectedImage)")
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func pickerDidCancel(_ picker: PHPickerViewController) {
        picker.dismiss(animated: true)
    }
}

extension DiaryCustomizerViewController {
    func deleteUserImage() {
        viewModel.selectedImage = UIImage(resource: .placeholderimage)
        isDefaultImage = true
    }
}

extension DiaryCustomizerViewController: TOCropViewControllerDelegate {
    
    private func userDidPickImage(_ image: UIImage) {
        print("this is image from did pck image: \(image)")
        viewModel.selectedImage = image
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        let resizedImage = image.resized(to: CGSize(width: 500, height: 500))
        userDidPickImage(resizedImage)
        isDefaultImage = false
        dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true)
    }
    
    private func resizeWithLanczos(image: UIImage, targetSize: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let scale = targetSize / max(image.size.width, image.size.height)
        
        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(scale, forKey: kCIInputScaleKey)
        filter?.setValue(1.0, forKey: kCIInputAspectRatioKey) // حفظ نسبت
        
        guard let outputCIImage = filter?.outputImage else { return nil }
        
        // Render با کیفیت بالا
        let context = CIContext(options: [
            .useSoftwareRenderer: false,           // از GPU استفاده کن
            .highQualityDownsample: true
        ])
        
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

extension DiaryCustomizerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = renameTextField.text ?? ""
        let nextText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if nextText.count > 50 {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == renameTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func dismissKeyboardTappingOutsideTextfield() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        print("gesture recognizer is working incorrectly")
    }
}

extension DiaryCustomizerViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardCancellables.forEach {
            $0.cancel()
        }
    }
    
    private func registerKeyboardNotifications() {
        NotificationCenter
            .default
            .publisher(for: UIApplication.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self else { return }
                self.keyboardWillShow(notification)
            }
            .store(in: &keyboardCancellables)
        NotificationCenter
            .default
            .publisher(for: UIApplication.keyboardWillHideNotification)
            .sink { [weak self] notification in
                guard let self else { return }
                self.keyboardWillHide(notification)
            }
            .store(in: &keyboardCancellables)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardHeight,
            right: 0
        )
        scrollView.contentInset = contentInsets
        
        if renameTextField.isEditing {
            let textfieldFrame = renameTextFieldView.superview!.convert(renameTextFieldView.frame, to: scrollView)
            scrollView.scrollRectToVisible(textfieldFrame, animated: true)
        } else {
            let textviewFrame = diaryTextView.superview!.convert(diaryTextView.frame, to: scrollView)
            scrollView.scrollRectToVisible(textviewFrame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

extension DiaryCustomizerViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let current = textView.text ?? ""
        let nextText = (current as NSString).replacingCharacters(in: range, with: text)
        if nextText.count > 150 {
            return false
        }
        diaryTextPlaceHolder.isHidden = !nextText.isEmpty
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.textDiary = textView.text ?? ""
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        diaryTextPlaceHolder.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        diaryTextPlaceHolder.isHidden = !diaryTextView.text.isEmpty
    }
}
