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
    
    /// Store and starts child coordinator
    func coordinate<T: Coordinator>(to coordinator: T) -> Observable<T.CoordinationResult>
    
    /// Starts the current coordinator
    func start() -> Observable<CoordinationResult>
    
    /// Navigate to specified route
    func navigate(to route: CoordinationRoute) -> Completable
}

extension Coordinator {
    
    public func coordinate<T: Coordinator>(to coordinator: T) -> Observable<T.CoordinationResult> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onCompleted: { [weak self] in
                self?.free(coordinator: coordinator)
            })
    }
    
}
