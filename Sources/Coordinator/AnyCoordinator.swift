//
//  AnyCoordinator.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation

public protocol AnyCoordinator: AnyObject, Presentable {
    var parent: AnyCoordinator? { get set }
    var root: AnyCoordinator? { get }
    
    var router: AnyRouter { get }
    
    func store(coordinator: AnyCoordinator)
    func free(coordinator: AnyCoordinator)
}
