//
//  BaseCoordinator.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation
import RxSwift

open class BaseCoordinator<RouteType, ResultType>: Coordinator {
    public typealias CoordinationRoute = RouteType
    public typealias CoordinationResult = ResultType
    
    public weak var parent: AnyCoordinator?
    private(set) var children = [AnyCoordinator]()
    
    public var router: AnyRouter
    
    public let disposeBag = DisposeBag()
    
    public var root: AnyCoordinator? {
        if let parent = parent {
            return parent.root
        }
        return self
    }
    
    public init(router: AnyRouter) {
        self.router = router
    }
    
    private func index(of coordinator: AnyCoordinator) -> Int? {
        return children.firstIndex(where: { $0 === coordinator })
    }

    public func store(coordinator: AnyCoordinator) {
        if index(of: coordinator) != nil {
            return
        }
        if coordinator.parent != nil {
            coordinator.parent?.free(coordinator: coordinator)
        }
        coordinator.parent = self

        children.append(coordinator)
    }

    public func free(coordinator: AnyCoordinator) {
        if let index = index(of: coordinator) {
            coordinator.parent = nil
            children.remove(at: index)
        }
    }
    
    @discardableResult
    open func start() -> Observable<ResultType> {
        return .never()
    }
    
    @discardableResult
    open func navigate(to route: RouteType) -> TransitionState {
        return .empty()
    }

}
