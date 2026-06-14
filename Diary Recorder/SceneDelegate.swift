//
//  SceneDelegate.swift
//  Diary Recorder
//
//  Created by Masoud on 5/9/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewController = Calendar3ViewController.make()
        
        //UIView.appearance().semanticContentAttribute = .forceRightToLeft
        //RecorderMainPageViewController.make()
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.tintColor = .label
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

}

