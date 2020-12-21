//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit

public class NavigationRouter: BaseRouter<UINavigationController> {
    
    private var transitionEvent: TransitionEvent?
    
    public override var count: Int {
        return rootViewController.viewControllers.count
    }
    
    public override var viewControllers: [Presentable] {
        return rootViewController.viewControllers
    }
    
    public override func perform(_ transition: Transition) -> TransitionState {
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
            
            if rootViewController.delegate == nil {
                rootViewController.delegate = self
            }
            
            let state = createTransition(for: scene) { [weak self] in
                self?.transitionEvent = .completed(scene)
                self?.rootViewController.setViewControllers([viewController], animated: animated)
                self?.rootViewController.isNavigationBarHidden = hideBar
            }
            
            return state
        case .push(let scene, let animated):
            let viewController = scene.toPresentable()
                    
            if viewController is UINavigationController || rootViewController.viewControllers.contains(viewController) {
                return .empty()
            }
            
            if rootViewController.delegate == nil {
                rootViewController.delegate = self
            }
            
            let state = createTransition(for: scene) { [weak self] in
                self?.transitionEvent = .completed(scene)
                self?.rootViewController.pushViewController(viewController, animated: animated)
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
            
            let poppedViewController = viewControllers.popLast()
            
            viewControllers.append(viewController)
            
            if rootViewController.delegate == nil {
                rootViewController.delegate = self
            }
            
            let state = createTransition(for: scene) { [weak self] in
                self?.transitionEvent = .completed(scene)
                self?.rootViewController.setViewControllers(viewControllers, animated: animated)
            }
            
            if let poppedViewController = poppedViewController {
                updateTransitionState(.dismissed(poppedViewController))
            }
            
            return state
        case .pop(let animated):
            if rootViewController.viewControllers.count > 1 {
                if let viewController = rootViewController.viewControllers.last {
                    let state = createTransition(for: viewController) { [weak self] in
                        self?.transitionEvent = .dismissed(viewController)
                        self?.rootViewController.popViewController(animated: animated)
                    }
                    
                    return state
                }
            }
            return .empty()
        case .popTo(let scene, let animated):
            let viewController = scene.toPresentable()
            
            if let viewControllers = rootViewController.popToViewController(viewController, animated: animated) {
                viewControllers.forEach {
                    updateTransitionState(.dismissed($0))
                }
            }
            
            return .empty()
        case .popToRoot(let animated):
            let viewControllers = Array(rootViewController.viewControllers.dropFirst())
            
            rootViewController.popToRootViewController(animated: animated)
            
            viewControllers.forEach {
                updateTransitionState(.dismissed($0))
            }
            
            return .empty()
        default:
            return super.perform(transition)
        }
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let transitionEvent = transitionEvent {
            updateTransitionState(transitionEvent)
            self.transitionEvent = nil
        } else {
            if let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) {
                if !navigationController.viewControllers.contains(fromViewController) {
                    updateTransitionState(.dismissed(fromViewController))
                }
            }
        }
    }
    
}
