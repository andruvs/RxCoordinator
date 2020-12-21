//
//  BaseCoordinator.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation
import RxSwift

class BaseCoordinator<RouteType, ResultType>: Coordinator {
    typealias CoordinationRoute = RouteType
    typealias CoordinationResult = ResultType
    
    weak var parent: AnyCoordinator?
    private(set) var children = [AnyCoordinator]()
    
    var router: AnyRouter
    
    let disposeBag = DisposeBag()
    
    var root: AnyCoordinator? {
        if let parent = parent {
            return parent.root
        }
        return self
    }
    
    init(router: AnyRouter) {
        self.router = router
    }
    
    private func index(of coordinator: AnyCoordinator) -> Int? {
        return children.firstIndex(where: { $0 === coordinator })
    }

    func store(coordinator: AnyCoordinator) {
        if index(of: coordinator) != nil {
            return
        }
        if coordinator.parent != nil {
            coordinator.parent?.free(coordinator: coordinator)
        }
        coordinator.parent = self

        children.append(coordinator)
    }

    func free(coordinator: AnyCoordinator) {
        if let index = index(of: coordinator) {
            coordinator.parent = nil
            children.remove(at: index)
        }
    }
    
    @discardableResult
    func start() -> Observable<ResultType> {
        return .never()
    }
    
    func navigate(to route: RouteType) -> TransitionState {
        return .empty()
    }

}
