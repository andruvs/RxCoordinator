//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit

protocol Router: AnyRouter {
    associatedtype UIViewControllerType: UIViewController
    
    var rootViewController: UIViewControllerType { get }
}

extension Router {
    func toPresentable() -> UIViewController {
        return rootViewController
    }
}
