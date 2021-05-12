//
//  SceneDelegate.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let model = SearchModel()
        let viewController = SearchViewController(
            model: model
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        #warning("TODO: Collapse title area")
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
