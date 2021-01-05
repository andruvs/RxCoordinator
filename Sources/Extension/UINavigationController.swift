//
//  UINavigationController.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 05.01.2021.
//

import UIKit

internal extension UINavigationController {
    
    private func onComplete(animated: Bool, completion: (() -> Void)?) {
        guard let completion = completion else {
            return
        }
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        pushViewController(viewController, animated: animated)
        onComplete(animated: animated, completion: completion)
    }

    func popViewController(animated: Bool, completion: (() -> Void)?) {
        popViewController(animated: animated)
        onComplete(animated: animated, completion: completion)
    }

    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        popToViewController(viewController, animated: animated)
        onComplete(animated: animated, completion: completion)
    }
    
    func popToRootViewController(animated: Bool, completion: (() -> Void)?) {
        popToRootViewController(animated: animated)
        onComplete(animated: animated, completion: completion)
    }
    
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: (() -> Void)?) {
        setViewControllers(viewControllers, animated: animated)
        onComplete(animated: animated, completion: completion)
    }
}
