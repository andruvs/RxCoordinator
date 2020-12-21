//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit
import RxSwift

public class TabBarRouter: BaseRouter<UITabBarController> {
    
    public override var count: Int {
        return rootViewController.viewControllers?.count ?? 0
    }
    
    public override var viewControllers: [Presentable] {
        return rootViewController.viewControllers ?? []
    }
    
}
