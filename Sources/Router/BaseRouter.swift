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
    
    private let queue = TransitionQueue()
    
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
    
    private let _dismissed = PublishSubject<Presentable>()
    public var dismissed: Observable<Presentable> {
        return _dismissed.asObservable()
    }
    
    public func perform(_ transition: Transition) -> Completable {
        let closure = createClosure(for: transition)
        let task = TransitionTask(closure)
        
        queue.append(task)
        
        return task.state.completed
    }
    
    internal func createClosure(for transition: Transition) -> TransitionClosure? {
        switch transition {
        case .present(let scene, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                let viewController = scene.toPresentable()
                
                if let presentedViewController = self.rootViewController.presentedViewController, presentedViewController === viewController {
                    state.onError(.alreadyPresented)
                    state.onCompleted()
                    return
                }
                
                viewController.modalPresentationCapturesStatusBarAppearance = true
                viewController.modalPresentationStyle = .fullScreen
                
                if #available(iOS 13.0, *) {
                    viewController.isModalInPresentation = true
                }
                
                self.rootViewController.present(viewController, animated: animated) {
                    state.onCompleted()
                }
            }
        case .modal(let scene, let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                let viewController = scene.toPresentable()
                
                if let presentedViewController = self.rootViewController.presentedViewController, presentedViewController === viewController {
                    state.onError(.alreadyPresented)
                    state.onCompleted()
                    return
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
                
                self.rootViewController.present(viewController, animated: animated) {
                    state.onCompleted()
                }
            }
        case .dismiss(let animated):
            return { [weak self] state in
                guard let self = self else {
                    state.onError(.inconsistentState)
                    state.onCompleted()
                    return
                }
                
                guard let viewController = self.rootViewController.presentedViewController else {
                    state.onError(.nothingPresented)
                    state.onCompleted()
                    return
                }
                
                self.rootViewController.dismiss(animated: animated) { [weak self] in
                    self?.onDismissed(viewController)
                    state.onCompleted()
                }
            }
        default:
            return nil
        }
    }
    
    internal func onDismissed(_ scene: Presentable) {
        _dismissed.onNext(scene)
    }
    
    internal func onDismissed(_ scenes: [Presentable]) {
        for scene in scenes {
            _dismissed.onNext(scene)
        }
    }
}
