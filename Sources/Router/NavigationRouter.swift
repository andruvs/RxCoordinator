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
        
        return super.perform(transition)
    }
    
    internal override func createTransition(for transition: Transition) -> TransitionBlock? {
        switch transition {
        case .setBarHidden(let hidden, let animated):
            return { [weak self] _ in
                self?.rootViewController.setNavigationBarHidden(hidden, animated: animated)
                return true
            }
        case .setRoot(let scene, let hideBar, let animated):
            return { [weak self] state in
                guard let self = self else { return false }
            
                let viewController = scene.toPresentable()
                
                if viewController is UINavigationController {
                    return false
                }
                
                self.storeState(state, for: scene)
                
                let viewControllers = self.rootViewController.viewControllers
                if viewControllers.count > 0 {
                    viewControllers.forEach {
                        self.storeEvent(.dismissed($0))
                    }
                }
                
                self.storeEvent(.completed(scene))
                self.rootViewController.setViewControllers([viewController], animated: animated)
                self.rootViewController.isNavigationBarHidden = hideBar
                
                return true
            }
        case .push(let scene, let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                let viewController = scene.toPresentable()
                
                if viewController is UINavigationController || self.rootViewController.viewControllers.contains(viewController) {
                    return false
                }
                
                self.storeState(state, for: scene)
            
                self.storeEvent(.completed(scene))
                self.rootViewController.pushViewController(viewController, animated: animated)
                
                return true
            }
        case .replaceLast(let scene, let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                var viewControllers = self.rootViewController.viewControllers
                
                if viewControllers.count == 0 {
                    return false
                }
                
                let viewController = scene.toPresentable()
                
                if viewController is UINavigationController || viewControllers.contains(viewController) {
                    return false
                }
                
                self.storeState(state, for: scene)
                
                if let poppedViewController = viewControllers.popLast() {
                    self.storeEvent(.dismissed(poppedViewController))
                }
                
                viewControllers.append(viewController)
                
                self.storeEvent(.completed(scene))
                self.rootViewController.setViewControllers(viewControllers, animated: animated)
                
                return true
            }
        case .pop(let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                guard let viewController = self.rootViewController.viewControllers.last else {
                    return false
                }
                
                self.storeState(state, for: viewController)
                
                self.storeEvent(.dismissed(viewController))
                self.rootViewController.popViewController(animated: animated)
                
                return true
            }
        case .popTo(let scene, let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                let viewController = scene.toPresentable()
                
                guard let index = self.rootViewController.viewControllers.lastIndex(of: viewController) else {
                    return false
                }
                
                let poppedViewControllers = self.rootViewController.viewControllers.suffix(from: index.advanced(by: 1))
                if poppedViewControllers.isEmpty {
                    return false
                }
                
                if let lastViewController = poppedViewControllers.last {
                    self.storeState(state, for: lastViewController)
                }
                
                poppedViewControllers.forEach {
                    self.storeEvent(.dismissed($0))
                }
                
                self.rootViewController.popToViewController(viewController, animated: animated)
                
                return true
            }
        case .popToRoot(let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                if self.rootViewController.viewControllers.count < 2 {
                    return false
                }
                
                let poppedViewControllers = self.rootViewController.viewControllers.dropFirst()
                
                if let lastViewController = poppedViewControllers.last {
                    self.storeState(state, for: lastViewController)
                }
                
                poppedViewControllers.forEach {
                    self.storeEvent(.dismissed($0))
                }
                
                self.rootViewController.popToRootViewController(animated: animated)
                
                return true
            }
        default:
            return super.createTransition(for: transition)
        }
    }
    
    private func clearEvents() {
        transitionEvents.removeAll()
    }
    
    private func storeEvent(_ event: TransitionEvent) {
        transitionEvents.append(event)
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !transitionEvents.isEmpty {
            transitionEvents.forEach {
                updateTransitionState($0)
            }
            clearEvents()
        } else {
            if let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) {
                if !navigationController.viewControllers.contains(fromViewController) {
                    updateTransitionState(.dismissed(fromViewController))
                }
            }
        }
    }
    
}
