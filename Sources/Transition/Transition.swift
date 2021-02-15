//
//  AnyRouter.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

public enum Transition {
    case setBarHidden(_ hidden: Bool, animated: Bool = true)
    case setRoot(_ scene: Presentable, hideBar: Bool = false, animated: Bool = true)
    case set(_ scenes: [Presentable], animated: Bool = true)
    case push(_ scene: Presentable, animated: Bool = true)
    case replaceLast(with: Presentable, animated: Bool = true)
    case pop(animated: Bool = true)
    case popTo(_ scene: Presentable, animated: Bool = true)
    case popToRoot(animated: Bool = true)
    case present(_ scene: Presentable, animated: Bool = true)
    case modal(_ scene: Presentable, animated: Bool = true)
    case dismiss(animated: Bool = true)
    case setTab(_ scene: Presentable, index: Int, animated: Bool = true)
    case selectTab(_ index: Int)
}
