//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit
import RxSwift

class TabBarRouter: BaseRouter<UITabBarController> {
    
    override var count: Int {
        return rootViewController.viewControllers?.count ?? 0
    }
    
    override var viewControllers: [Presentable] {
        return rootViewController.viewControllers ?? []
    }
    
}
