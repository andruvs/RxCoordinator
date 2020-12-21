//
//  TransitionEvent.swift
//  Articulation
//
//  Created by Andrey Golovchak on 19/10/2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import UIKit

internal enum TransitionEvent {
    case completed(_ scene: Presentable)
    case dismissed(_ scene: Presentable)
    
    var scene: Presentable {
        switch self {
        case .completed(let scene):
            return scene
        case .dismissed(let scene):
            return scene
        }
    }
}
