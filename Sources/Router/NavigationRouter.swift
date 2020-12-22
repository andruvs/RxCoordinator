//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit

public class NavigationRouter: BaseRouter<UINavigationController> {
    
    private var transitionEvents = [TransitionEvent]()
    
    public override var count: Int {
        return rootViewController.viewControllers.count
    }
    
    public override var viewControllers: [Presentable] {
        return rootViewController.viewControllers
    }
    
    public override func perform(_ transition: Transition) -> TransitionState {
        if rootViewController.delegate == nil {
            rootViewController.delegate = self
        }
        
        clearTransitionEvents()
        
        switch transition {
        case .setBarHidden(let hidden, let animated):
            rootViewController.setNavigationBarHidden(hidden, animated: animated)
            return .empty()
        case .setRoot(let scene, let hideBar, let animated):
            let viewControllers = rootViewController.viewControllers
            if viewControllers.count > 0 {
                viewControllers.forEach {
                    updateTransitionState(.dismissed($0))
                }
            }
            
            let viewController = scene.toPresentable()
            
            if viewController is UINavigationController {
                return .empty()
            }
            
            let state = createTransition(for: scene) { [weak self] in
                if let self = self {
                    self.storeTransitionEvent(.completed(scene))
                    self.rootViewController.setViewControllers([viewController], animated: animated)
                    self.rootViewController.isNavigationBarHidden = hideBar
                }
            }
            
            return state
        case .push(let scene, let animated):
            let viewController = scene.toPresentable()
                    
            if viewController is UINavigationController || rootViewController.viewControllers.contains(viewController) {
                return .empty()
            }
            
            let state = createTransition(for: scene) { [weak self] in
                if let self = self {
                    self.storeTransitionEvent(.completed(scene))
                    self.rootViewController.pushViewController(viewController, animated: animated)
                }
            }
            
            return state
        case .replaceLast(let scene, let animated):
            var viewControllers = rootViewController.viewControllers
            
            if viewControllers.count == 0 {
                return .empty()
            }
            
            let viewController = scene.toPresentable()
            
            if viewController is UINavigationController || viewControllers.contains(viewController) {
                return .empty()
            }
            
            if let poppedViewController = viewControllers.popLast() {
                storeTransitionEvent(.dismissed(poppedViewController))
            }
            
            viewControllers.append(viewController)
            
            let state = createTransition(for: scene) { [weak self] in
                if let self = self {
                    self.storeTransitionEvent(.completed(scene))
                    self.rootViewController.setViewControllers(viewControllers, animated: animated)
                }
            }
            
            return state
        case .pop(let animated):
            if rootViewController.viewControllers.count > 1 {
                if let viewController = rootViewController.viewControllers.last {
                    let state = createTransition(for: viewController) { [weak self] in
                        if let self = self {
                            self.storeTransitionEvent(.dismissed(viewController))
                            self.rootViewController.popViewController(animated: animated)
                        }
                    }
                    return state
                }
            }
            return .empty()
        case .popTo(let scene, let animated):
            let viewController = scene.toPresentable()
            
            if let index = rootViewController.viewControllers.lastIndex(of: viewController) {
                let poppedViewControllers = rootViewController.viewControllers.suffix(from: index.advanced(by: 1))
                poppedViewControllers.forEach {
                    storeTransitionEvent(.dismissed($0))
                }
                
                let state = createTransition(for: viewController) { [weak self] in
                    if let self = self {
                        self.storeTransitionEvent(.completed(viewController))
                        self.rootViewController.popToViewController(viewController, animated: animated)
                    }
                }
                
                return state
            }
            
//            if let viewControllers = rootViewController.popToViewController(viewController, animated: animated) {
//                viewControllers.forEach {
//                    updateTransitionState(.dismissed($0))
//                }
//            }
            
            return .empty()
        case .popToRoot(let animated):
            if let viewController = rootViewController.viewControllers.first {
                let poppedViewControllers = rootViewController.viewControllers.dropFirst()
                poppedViewControllers.forEach {
                    storeTransitionEvent(.dismissed($0))
                }
                
                let state = createTransition(for: viewController) { [weak self] in
                    if let self = self {
                        self.storeTransitionEvent(.completed(viewController))
                        self.rootViewController.popToRootViewController(animated: animated)
                    }
                }
                
                return state
            }
            
//            rootViewController.popToRootViewController(animated: animated)
//
//            viewControllers.forEach {
//                updateTransitionState(.dismissed($0))
//            }
            
            return .empty()
        default:
            return super.perform(transition)
        }
    }
    
    private func clearTransitionEvents() {
        transitionEvents.removeAll()
    }
    
    private func storeTransitionEvent(_ event: TransitionEvent) {
        transitionEvents.append(event)
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !transitionEvents.isEmpty {
            transitionEvents.forEach {
                updateTransitionState($0)
            }
            clearTransitionEvents()
        } else {
            if let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) {
                if !navigationController.viewControllers.contains(fromViewController) {
                    updateTransitionState(.dismissed(fromViewController))
                }
            }
        }
    }
    
}
