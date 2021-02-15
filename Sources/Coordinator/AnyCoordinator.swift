//
//  AnyCoordinator.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit
import RxSwift

public protocol AnyCoordinator: Presentable {
    
    /// Parent coordinator or nil if there is no one
    var parent: AnyCoordinator? { get set }
    
    /// Top most coordinator for a given coordinator chain hierarchy
    var root: AnyCoordinator? { get }
    
    /// Array of child coordinators
    var children: [AnyCoordinator] { get set }
    
    /// Router that implements navigation for a given coordinator
    var router: AnyRouter { get }
    
    /// Store child coordinator
    func store(coordinator: AnyCoordinator)
    
    /// Free child coordinator
    func free(coordinator: AnyCoordinator)
    
    /// Navigate to specified routes chain
    func navigate(to routes: [Route]) -> Completable
    
    /// Checks if the coordinator contains the specified route
    func hasRoute(_ route: Route) -> Bool
}

extension AnyCoordinator {
    
    public var root: AnyCoordinator? {
        if let parent = parent {
            return parent.root
        }
        return self
    }
    
    private func index(of coordinator: AnyCoordinator) -> Int? {
        return children.firstIndex(where: { $0 === coordinator })
    }
    
    public func store(coordinator: AnyCoordinator) {
        if index(of: coordinator) != nil {
            return
        }
        
        coordinator.parent?.free(coordinator: coordinator)
        coordinator.parent = self

        children.append(coordinator)
    }

    public func free(coordinator: AnyCoordinator) {
        if let index = index(of: coordinator) {
            coordinator.parent = nil
            children.remove(at: index)
        }
    }
    
}

extension AnyCoordinator {
    public func toPresentable() -> UIViewController {
        return router.toPresentable()
    }
}
