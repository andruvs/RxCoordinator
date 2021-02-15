//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit
import RxSwift

public class TabBarRouter: BaseRouter<UITabBarController> {
    
    public override var count: Int {
        return rootViewController.viewControllers?.count ?? 0
    }
    
    public override var viewControllers: [Presentable] {
        return rootViewController.viewControllers ?? []
    }
    
    internal override func createClosure(for transition: Transition) -> TransitionClosure? {
        switch transition {
        case .set(let scenes, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                let viewControllers = scenes.map { $0.toPresentable() }
                let dismissedViewControllers = self.rootViewController.viewControllers
                
                self.rootViewController.setViewControllers(viewControllers, animated: animated)
                
                if let dismissedViewControllers = dismissedViewControllers {
                    self.onDismissed(dismissedViewControllers)
                }
                
                state.onCompleted()
            }
        case .setTab(let scene, let index, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                var viewControllers = self.rootViewController.viewControllers ?? []
                
                if index >= viewControllers.count {
                    state.onError(.outOfBoundaries)
                    state.onCompleted()
                    return
                }
                
                let viewController = scene.toPresentable()
                let dismissedViewController = viewControllers[index]
                
                viewControllers[index] = viewController
                
                self.rootViewController.setViewControllers(viewControllers, animated: animated)
                
                self.onDismissed(dismissedViewController)
                
                state.onCompleted()
            }
        case .selectTab(let index):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                let count = self.rootViewController.viewControllers?.count ?? 0
                
                if index >= count {
                    state.onError(.outOfBoundaries)
                    state.onCompleted()
                    return
                }
                
                self.rootViewController.selectedIndex = index
                
                state.onCompleted()
            }
        default:
            return super.createClosure(for: transition)
        }
    }
    
}
