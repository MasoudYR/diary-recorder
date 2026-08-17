//
//  ContactUsRouter.swift
//  Diary Recorder
//
//  Created by Masoud on 8/6/26.
//

import Foundation
import UIKit
import MessageUI

class ContactUsRouter: NSObject, MFMailComposeViewControllerDelegate {
    
    weak var contactUsViewController: ContactUsViewController?
    
    override init() {
        
    }
    
    func openURL(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func sendEmail(){
        guard MFMailComposeViewController.canSendMail() else {
            openMailto()
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["myazdanirad@gmail.com"])
        mail.setSubject("Diary Recorder Support")
        mail.setMessageBody("Hi Masoud,\n\n", isHTML: false)
        
        guard let contactUsViewController else { return }
        contactUsViewController.present(mail, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        controller.dismiss(animated: true)
    }
    
    private func openMailto() {
        print("function open mail to called:")
        let email = "myazdanirad@gmail.com"
        let subject = "Diary Recorder Support"
        let body = "Hi Masoud,\n\n"
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

