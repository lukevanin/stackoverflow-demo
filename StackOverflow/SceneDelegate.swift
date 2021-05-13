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
//        let viewController = SearchViewController(
//            model: model
//        )
        let viewController = QuestionViewController(
            model: SearchResultViewModel(
                id: "69",
                title: "What is the answer to the ultimate question of life, the universe, and everything?",
                owner: SearchResultViewModel.Owner(
                    displayName: "Deep Thought",
                    reputation: 101,
                    profileImageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/IBM_Blue_Gene_P_supercomputer.jpg/330px-IBM_Blue_Gene_P_supercomputer.jpg")!
                ),
                votes: 12,
                answers: 42,
                views: 1,
                answered: false,
                askedDate: Date(),
                content: "What is the answer to the ultimate question of life, the universe, and everything? Need this ASAP. kThx.",
                tags: ["life", "universe", "yolo"]
            )
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
