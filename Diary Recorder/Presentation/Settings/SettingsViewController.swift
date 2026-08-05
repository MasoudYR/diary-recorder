//
//  SettingsViewController.swift
//  Diary Recorder
//
//  Created by Masoud on 8/1/26.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    private let viewModel: SettingsViewModel
    private let router: SettingsRouter
    
    private let kVersion = "CFBundleShortVersionString"
    private let kBuildNumber = "CFBundleVersion"
    
    private let headerParentView = UIView()
    private let vStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let versionLabel = UILabel()
    
    private let settingsTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let messageLabel = UILabel()
    
    
    
    init(viewModel: SettingsViewModel, router: SettingsRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router.settingsViewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make() -> SettingsViewController {
        let viewModel = SettingsViewModel()
        let router = SettingsRouter()
        let viewController = SettingsViewController(viewModel: viewModel, router: router)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarUI()
        setupUI()
    }
    
    private func setupNavigationBarUI() {
        navigationItem.title = "Settings"
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.roundedFont(ofSize: 25, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        //appearance.backgroundColor = UIColor.init(named: "MainColor")
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance
        navigationItem.backButtonTitle = ""
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.init(named: "MainColor")
        setupHeaderParentView()
        setupVStackView()
        setupIconImageView()
        setupAppLabelsParentView()
        setVersionAndBuildNumberValues()
        setupMessageLabel()
        setupSettingsTableView()
    }
    
    private func setupHeaderParentView() {
        headerParentView.frame = CGRect(origin: .zero, size: CGSize(width: .zero, height: 220))
    }
    
    private func setupVStackView() {
        vStackView.axis = .vertical
        vStackView.distribution = .fill
        vStackView.alignment = .center
        vStackView.spacing = 10
        
        headerParentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
    }
    
    private func setupIconImageView() {
        iconImageView.image = UIImage(resource: .placeholderimage)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 20
        iconImageView.layer.masksToBounds = true
        
        vStackView.addArrangedSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(120)
        }
    }
    
    private func setupAppLabelsParentView() {
        appNameLabel.text = "Diary Recorder"
        appNameLabel.font = .roundedFont(ofSize: 20, weight: .semibold)
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        
        vStackView.addArrangedSubview(appNameLabel)
        vStackView.setCustomSpacing(5, after: appNameLabel)
        
        versionLabel.text = "Version -.-.-(-)"
        versionLabel.font = .roundedFont(ofSize: 17, weight: .regular)
        versionLabel.textColor = .gray
        versionLabel.textAlignment = .center
        
        vStackView.addArrangedSubview(versionLabel)
    }
    
    private func setupMessageLabel() {
        messageLabel.text = "All your diaries stay on this device."
        messageLabel.font = .roundedFont(ofSize: 17, weight: .regular)
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.frame = CGRect(origin: .zero, size: CGSize(width: .zero, height: 50))
    }
    
    private func setupSettingsTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.rowHeight = 60
        settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        
        settingsTableView.tableHeaderView = headerParentView
        settingsTableView.tableFooterView = messageLabel
        settingsTableView.backgroundColor = .main
        view.addSubview(settingsTableView)
        
        settingsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setVersionAndBuildNumberValues() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        let buildNumber = dictionary[kBuildNumber] as! String
        versionLabel.text = "Version \(version) (\(buildNumber))"
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
        //cell.selectionStyle = .
        
        switch indexPath.section {
        case 0:
            cell.configue(
                iconImage: UIImage(systemName: "info.circle")!,
                iconTintColor: .main,
                iconBackgroundColor: .reverseMain,
                title: "About"
            )
        case 1:
            if indexPath.row == 0 {
                cell.configue(
                    iconImage: UIImage(systemName: "lock")!,
                    iconTintColor: .main,
                    iconBackgroundColor: .reverseMain,
                    title: "Privacy policy"
                )
            } else {
                cell.configue(
                    iconImage: UIImage(systemName: "text.document")!,
                    iconTintColor: .main,
                    iconBackgroundColor: .reverseMain,
                    title: "Terms of service"
                )
            }
        case 2:
            cell.configue(
                iconImage: UIImage(systemName: "envelope")!,
                iconTintColor: .main,
                iconBackgroundColor: .reverseMain,
                title: "Contact us"
            )
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.router.navigateToAboutViewController()
        case 1:
            if indexPath.row == 0 {
                self.router.navigateToPrivacyPolicyViewController()
            } else {
                self.router.navigateToTermsOfServiceViewController()
            }
        case 2:
            //go to contact us view
            ()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
            cell.selectionChanged(isSelected: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
            cell.selectionChanged(isSelected: false)
        }
    }
}
