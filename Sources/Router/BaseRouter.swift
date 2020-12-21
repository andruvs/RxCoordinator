//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit

open class BaseRouter<T: UIViewController>: NSObject, Router {
    public let rootViewController: T
    
    public init(viewController: T = T()) {
        rootViewController = viewController
    }
    
    open var count: Int {
        return 1
    }
    
    open var viewControllers: [Presentable] {
        return []
    }
    
    open func perform(_ transition: Transition) -> TransitionState {
        switch transition {
        case .present(let scene, let animated):
            let viewController = scene.toPresentable()
            
            if let vc = rootViewController.presentedViewController, vc === viewController {
                return .empty()
            }
            
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.modalPresentationStyle = .fullScreen
            
            if #available(iOS 13.0, *) {
                viewController.isModalInPresentation = true
            }
            
            let state = createTransition(for: scene) { [weak self] in
                self?.rootViewController.present(viewController, animated: animated) {
                    self?.updateTransitionState(.completed(scene))
                }
            }
            
            return state
        case .modal(let scene, let animated):
            let viewController = scene.toPresentable()
            
            if let vc = rootViewController.presentedViewController, vc === viewController {
                return .empty()
            }
            
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.modalPresentationStyle = .fullScreen
            viewController.providesPresentationContextTransitionStyle = true
            viewController.definesPresentationContext = true
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .crossDissolve
            
            if #available(iOS 13.0, *) {
                viewController.isModalInPresentation = true
            }
            
            let state = createTransition(for: scene) { [weak self] in
                self?.rootViewController.present(viewController, animated: animated) {
                    self?.updateTransitionState(.completed(scene))
                }
            }
            
            return state
        case .dismiss(let animated):
            guard let viewController = rootViewController.presentedViewController else {
                return .empty()
            }
            
            let state = createTransition(for: viewController) { [weak self] in
                self?.rootViewController.dismiss(animated: animated) {
                    self?.updateTransitionState(.dismissed(viewController))
                }
            }
            
            return state
        default:
            return .empty()
        }
    }
    
    private var states = [UIViewController: [TransitionState]]()
    
    internal func createTransition(for scene: Presentable, transition: (() -> Void)?) -> TransitionState {
        let viewController = scene.toPresentable()
        let state = TransitionState()
        
        var newStates = states[viewController] ?? [TransitionState]()
        newStates.append(state)
        states[viewController] = newStates
        
        if let transition = transition {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: transition)
        }
        
        return state
    }
    
    internal func updateTransitionState(_ event: TransitionEvent) {
        let viewController = event.scene.toPresentable()
        var remove = false
        
        if let states = states[viewController] {
            states.forEach { state in
                switch event {
                case .completed:
                    state.complete()
                case .dismissed:
                    state.dismiss()
                    remove = true
                }
            }
        }
        
        if remove {
            states.removeValue(forKey: viewController)
        }
    }
}
