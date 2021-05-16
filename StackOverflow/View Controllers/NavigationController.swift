//
//  NavigationController.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/13.
//

import UIKit

/// Wrapper for `UINavigationController` to force the style of the status bar. When a navigation
/// controller is used, the status bar style is controlled by the `UINavBar`, which responds to the device
/// settings for dark and light mode (light status bar in dark mode, and dark status bar in normal mode). For
/// our specific app we would like the status bar to always be light.
final class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
