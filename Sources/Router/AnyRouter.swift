//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public protocol AnyRouter: Presentable {
    var count: Int { get }
    var viewControllers: [Presentable] { get }
    @discardableResult
    func perform(_ transition: Transition) -> TransitionState
}
