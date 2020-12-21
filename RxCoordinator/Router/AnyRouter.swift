//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation

protocol AnyRouter: Presentable {
    var count: Int { get }
    var viewControllers: [Presentable] { get }
    @discardableResult
    func perform(_ transition: Transition) -> TransitionState
}
