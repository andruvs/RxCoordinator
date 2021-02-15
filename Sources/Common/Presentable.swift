//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import UIKit

public protocol Presentable: AnyObject {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    
    public func toPresentable() -> UIViewController {
        return self
    }
}
