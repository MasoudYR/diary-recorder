//
//  SettingsRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 8/1/26.
//

import Foundation
import SafariServices

class SettingsRouter {
    
    weak var settingsViewController: SettingsViewController?
    
    init() {
        
    }
    
    func navigateToAboutViewController() {
        guard let settingsViewController,
              let navigationViewController = settingsViewController.navigationController else { return }
        
        let aboutViewController = AboutViewController.make()
        navigationViewController.pushViewController(aboutViewController, animated: true)
    }
    
    func navigateToPrivacyPolicyViewController() {
        guard let settingsViewController,
              let navigationViewController = settingsViewController.navigationController else { return }
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = true
        configuration.entersReaderIfAvailable = false
        
        let url = URL(string: "https://www.google.com")!
        let privacyPolicyViewController = SFSafariViewController(url: url, configuration: configuration)
        navigationViewController.present(privacyPolicyViewController, animated: true
        )
    }
    
    func navigateToTermsOfServiceViewController() {
        guard let settingsViewController,
              let navigationViewController = settingsViewController.navigationController else { return }
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = true
        configuration.entersReaderIfAvailable = false
        
        let url = URL(string: "https://www.google.com")!
        let termsOfServiceViewController = SFSafariViewController(url: url, configuration: configuration)
        navigationViewController.present(termsOfServiceViewController, animated: true
        )
    }
}
