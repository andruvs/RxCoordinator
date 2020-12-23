//
//  TransitionTask.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 22.12.2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation

typealias TransitionBlock = ((TransitionState) -> Bool)

class TransitionTask {
    
    let state: TransitionState
    let transition: TransitionBlock?
    
    init(_ transition: TransitionBlock?) {
        self.transition = transition
        self.state = TransitionState()
    }
    
}
