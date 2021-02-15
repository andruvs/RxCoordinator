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
    public var children = [AnyCoordinator]()
    
    public var router: AnyRouter
    
    public let disposeBag = DisposeBag()
    
    public init(router: AnyRouter) {
        self.router = router
    }
    
    @discardableResult
    open func start() -> Observable<ResultType> {
        return .never()
    }
    
    public func hasRoute(_ route: Route) -> Bool {
        return route is RouteType
    }
    
    @discardableResult
    open func navigate(to route: RouteType) -> Completable {
        return .empty()
    }
    
    @discardableResult
    public func navigate(to routes: [Route]) -> Completable {
        var completed: Completable = .empty()
        var remainRoutes = routes
        
        for route in routes {
            if let route = route as? RouteType {
                completed = navigate(to: route)
                remainRoutes = Array(remainRoutes.dropFirst())
            } else {
                var routeFound = false
                
                for coordinator in children {
                    if coordinator.hasRoute(route) {
                        routeFound = true
                        completed = coordinator.navigate(to: remainRoutes)
                        break
                    }
                }
                
                assert(routeFound, "Route \(route) not found")
                break
            }
        }
        
        return completed
    }

}
