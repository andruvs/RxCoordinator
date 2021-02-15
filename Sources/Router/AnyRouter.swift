//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import RxSwift

public protocol AnyRouter: Presentable {
    /// The number of controllers in this router
    var count: Int { get }
    
    /// Array of controllers in the root controller
    var viewControllers: [Presentable] { get }
    
    /// Dismissed controllers
    var dismissed: Observable<Presentable> { get }
    
    /// Performs transition segue
    @discardableResult
    func perform(_ transition: Transition) -> Completable
}
