//
//  AnyRouter.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation

enum Transition {
    case setBarHidden(_ hidden: Bool, animated: Bool = true)
    case setRoot(_ scene: Presentable, hideBar: Bool = false, animated: Bool = true)
    case push(_ scene: Presentable, animated: Bool = true)
    case replaceLast(with: Presentable, animated: Bool = true)
    case pop(animated: Bool = true)
    case popTo(_ scene: Presentable, animated: Bool = true)
    case popToRoot(animated: Bool = true)
    case present(_ scene: Presentable, animated: Bool = true)
    case modal(_ scene: Presentable, animated: Bool = true)
    case dismiss(animated: Bool = true)
}