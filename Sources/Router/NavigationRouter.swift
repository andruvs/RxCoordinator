//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit
import RxSwift

public class NavigationRouter: BaseRouter<UINavigationController> {
    
    public override var count: Int {
        return rootViewController.viewControllers.count
    }
    
    public override var viewControllers: [Presentable] {
        return rootViewController.viewControllers
    }
    
    public override func perform(_ transition: Transition) -> Completable {
        if rootViewController.delegate == nil {
            rootViewController.delegate = self
        }
        
        return super.perform(transition)
    }
    
    internal override func createClosure(for transition: Transition) -> TransitionClosure? {
        switch transition {
        case .setBarHidden(let hidden, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                self.rootViewController.setNavigationBarHidden(hidden, animated: animated)
                
                state.onCompleted()
            }
        case .setRoot(let scene, let hideBar, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
            
                let viewController = scene.toPresentable()
                
                if viewController is UINavigationController {
                    state.onError(.isNavigationController)
                    state.onCompleted()
                    return
                }
                
                let dismissedViewControllers = self.rootViewController.viewControllers
                
                self.rootViewController.setViewControllers([viewController], animated: animated) { [weak self] in
                    self?.onDismissed(dismissedViewControllers)
                    state.onCompleted()
                }
                
                self.rootViewController.isNavigationBarHidden = hideBar
            }
        case .set(let scenes, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                var viewControllers = [UIViewController]()
                
                for scene in scenes {
                    let viewController = scene.toPresentable()
                    
                    if viewController is UINavigationController {
                        state.onError(.isNavigationController)
                        state.onCompleted()
                        return
                    }
                    
                    viewControllers.append(viewController)
                }
                
                let dismissedViewControllers = self.rootViewController.viewControllers
                
                self.rootViewController.setViewControllers(viewControllers, animated: animated) { [weak self] in
                    self?.onDismissed(dismissedViewControllers)
                    state.onCompleted()
                }
            }
        case .push(let scene, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                let viewController = scene.toPresentable()
                
                if viewController is UINavigationController {
                    state.onError(.isNavigationController)
                    state.onCompleted()
                    return
                }
                
                if self.rootViewController.viewControllers.contains(viewController) {
                    state.onError(.alreadyPushed)
                    state.onCompleted()
                    return
                }
            
                self.rootViewController.pushViewController(viewController, animated: animated) {
                    state.onCompleted()
                }
            }
        case .replaceLast(let scene, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                var viewControllers = self.rootViewController.viewControllers
                
                if viewControllers.count == 0 {
                    state.onCompleted()
                    return
                }
                
                let viewController = scene.toPresentable()
                
                if viewController is UINavigationController {
                    state.onError(.isNavigationController)
                    state.onCompleted()
                    return
                }
                
                if viewControllers.contains(viewController) {
                    state.onError(.alreadyPushed)
                    state.onCompleted()
                    return
                }
                
                let dismissedViewController = viewControllers.popLast()
                
                viewControllers.append(viewController)
                
                self.rootViewController.setViewControllers(viewControllers, animated: animated) { [weak self] in
                    if let dismissedViewController = dismissedViewController {
                        self?.onDismissed(dismissedViewController)
                    }
                    state.onCompleted()
                }
            }
        case .pop(let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                guard let dismissedViewController = self.rootViewController.viewControllers.last else {
                    state.onCompleted()
                    return
                }
                
                self.rootViewController.popViewController(animated: animated) { [weak self] in
                    self?.onDismissed(dismissedViewController)
                    state.onCompleted()
                }
            }
        case .popTo(let scene, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                let viewController = scene.toPresentable()
                
                guard let index = self.rootViewController.viewControllers.lastIndex(of: viewController) else {
                    state.onError(.notFound)
                    state.onCompleted()
                    return
                }
                
                let dismissedViewControllers = self.rootViewController.viewControllers.suffix(from: index.advanced(by: 1))
                if dismissedViewControllers.isEmpty {
                    state.onCompleted()
                    return
                }
                
                self.rootViewController.popToViewController(viewController, animated: animated) { [weak self] in
                    self?.onDismissed(Array(dismissedViewControllers))
                    state.onCompleted()
                }
            }
        case .popToRoot(let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                if self.rootViewController.viewControllers.count < 2 {
                    state.onCompleted()
                    return
                }
                
                let dismissedViewControllers = self.rootViewController.viewControllers.dropFirst()
                
                self.rootViewController.popToRootViewController(animated: animated) { [weak self] in
                    self?.onDismissed(Array(dismissedViewControllers))
                    state.onCompleted()
                }
            }
        default:
            return super.createClosure(for: transition)
        }
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) {
            if !navigationController.viewControllers.contains(fromViewController) {
                self.onDismissed(fromViewController)
            }
        }
    }
    
}
