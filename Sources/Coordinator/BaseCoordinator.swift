//
//  BaseCoordinator.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import RxSwift

open class BaseCoordinator<RouteType: Route, ResultType>: Coordinator {
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
    
    public func hasRoute(_ route: Route) -> Bool {
        return route is RouteType
    }
    
    @discardableResult
    open func navigate(to route: RouteType) -> TransitionState {
        return .empty()
    }
    
    @discardableResult
    public func navigate(to routes: [Route]) -> TransitionState {
        var state: TransitionState = .empty()
        var remainRoutes = routes
        
        for route in routes {
            if let route = route as? RouteType {
                state = navigate(to: route)
                remainRoutes = Array(remainRoutes.dropFirst())
            } else {
                var routeFound = false
                
                for coordinator in children {
                    if coordinator.hasRoute(route) {
                        routeFound = true
                        state = coordinator.navigate(to: remainRoutes)
                        break
                    }
                }
                
                assert(routeFound, "Route \(route) not found")
                break
            }
        }
        
        return state
    }

}
