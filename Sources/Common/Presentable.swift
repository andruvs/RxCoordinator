//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit

protocol Presentable {
    func toPresentable() -> UIViewController
}

extension UIViewController: Presentable {
    
    func toPresentable() -> UIViewController {
        return self
    }
}
