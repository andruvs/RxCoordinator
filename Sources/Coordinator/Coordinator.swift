//
//  AnyCoordinator.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import RxSwift

public protocol Coordinator: AnyCoordinator {
    associatedtype CoordinationResult
    associatedtype CoordinationRoute: Route
    
    func coordinate<T: Coordinator>(to coordinator: T) -> Observable<T.CoordinationResult>
    func start() -> Observable<CoordinationResult>
    func navigate(to route: CoordinationRoute) -> TransitionState
}

extension Coordinator {
    
    public func coordinate<T: Coordinator>(to coordinator: T) -> Observable<T.CoordinationResult> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onCompleted: { [weak self] in
                self?.free(coordinator: coordinator)
            })
    }
    
    public func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
    
}
