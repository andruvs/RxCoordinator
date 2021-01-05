//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit
import RxSwift

public class BaseRouter<T: UIViewController>: NSObject, Router {
    
    private let disposeBag = DisposeBag()
    
    private var states = [UIViewController: [TransitionState]]()
    private var queue = [TransitionTask]()
    private var isRunning = false
    
    public let rootViewController: T
    
    public init(viewController: T = T()) {
        rootViewController = viewController
    }
    
    public var count: Int {
        return 1
    }
    
    public var viewControllers: [Presentable] {
        return []
    }
    
    public func perform(_ transition: Transition) -> TransitionState {
        let task = TransitionTask(createTransition(for: transition))
        
        queue.append(task)
        
        DispatchQueue.main.async { [weak self] in
            self?.checkQueue()
        }
        
        return task.state
    }
    
    internal func createTransition(for transition: Transition) -> TransitionBlock? {
        switch transition {
        case .present(let scene, let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                let viewController = scene.toPresentable()
                
                if let presentedViewController = self.rootViewController.presentedViewController, presentedViewController === viewController {
                    return false
                }
                
                viewController.modalPresentationCapturesStatusBarAppearance = true
                viewController.modalPresentationStyle = .fullScreen
                
                if #available(iOS 13.0, *) {
                    viewController.isModalInPresentation = true
                }
                
                self.storeState(state, for: scene)
                
                self.rootViewController.present(viewController, animated: animated) { [weak self] in
                    self?.updateTransitionState(.completed(scene))
                }
            
                return true
            }
        case .modal(let scene, let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                let viewController = scene.toPresentable()
                
                if let presentedViewController = self.rootViewController.presentedViewController, presentedViewController === viewController {
                    return false
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
                
                self.storeState(state, for: scene)
                
                self.rootViewController.present(viewController, animated: animated) { [weak self] in
                    self?.updateTransitionState(.completed(scene))
                }
            
                return true
            }
        case .dismiss(let animated):
            return { [weak self] state in
                guard let self = self else { return false }
                
                guard let viewController = self.rootViewController.presentedViewController else {
                    return false
                }
                
                self.storeState(state, for: viewController)
                
                self.rootViewController.dismiss(animated: animated) { [weak self] in
                    self?.updateTransitionState(.dismissed(viewController))
                }
            
                return true
            }
        default:
            return nil
        }
    }
    
    private func checkQueue() {
        if isRunning || queue.isEmpty {
            return
        }
        
        isRunning = true
        
        let task = queue.removeFirst()
        
        task.state.completed
            .subscribe(onCompleted: { [weak self] in
                self?.isRunning = false
                self?.checkQueue()
            })
            .disposed(by: disposeBag)
        
        let result = task.transition?(task.state) ?? false
        
        if !result {
            task.state.dismiss()
        }
    }
    
    internal func storeState(_ state: TransitionState, for scene: Presentable) {
        let viewController = scene.toPresentable()

        var newStates = states[viewController] ?? [TransitionState]()
        newStates.append(state)
        states[viewController] = newStates
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
