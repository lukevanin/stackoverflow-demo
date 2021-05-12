//
//  SceneDelegate.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit

import StackOverflowAPI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        let themeColor = UIColor(named: "ThemeColor")
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = themeColor
        navigationBarAppearance.barStyle = .black
        navigationBarAppearance.isTranslucent = false
        
        let searchBarAppearance = UISearchBar.appearance()
        searchBarAppearance.tintColor = .white

        let searchBarTextFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchBarTextFieldAppearance.defaultTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let baseURL = URL(string: "https://api.stackexchange.com/2.2/")!
        
        let urlSession = URLSession.shared
        
        let model = SearchModel(
            configuration: SearchModel.Configuration(
                maximumResults: 20
            ),
            service: QuestionsService(
                baseURL: baseURL,
                session: urlSession
            )
        )
        let viewController = SearchViewController(
            model: model
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.navigationBar.barStyle = .black
        #warning("TODO: Collapse title area")
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
