//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit

public protocol Router: AnyRouter {
    associatedtype UIViewControllerType: UIViewController
    
    /// Root controller responsible for navigation
    var rootViewController: UIViewControllerType { get }
}

extension Router {
    public func toPresentable() -> UIViewController {
        return rootViewController
    }
}
