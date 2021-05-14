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
        setupAppearance()
        let viewController = makeViewController()
        let navigationController = NavigationController(
            rootViewController: viewController
        )
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func makeViewController() -> UIViewController {
        let baseURL = URL(string: "https://api.stackexchange.com/2.2/")!
        
        let urlSession = URLSession.shared
        
        #warning("TODO: Replace mock with real service")
        
        let model = SearchModel(
            configuration: SearchModel.Configuration(
                maximumResults: 20
            ),
            service: QuestionsService(
                baseURL: baseURL,
                session: urlSession
            )
//            service: MockQuestionsService()
        )
        let viewModel = SearchViewModel(
            model: model
        )
        let viewController = SearchViewController(
            viewModel: viewModel
        )
        return viewController
    }

    private func setupAppearance() {
        let themeColor = UIColor(named: "ThemeColor")
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.barTintColor = themeColor
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "ThemeTextColor") as Any
        ]
    }
}
