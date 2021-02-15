//
//  TransitionError.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 12.02.2021.
//

import Foundation

public enum TransitionError: Error {
    case inconsistentState
    case alreadyPresented
    case nothingPresented
    case isNavigationController
    case alreadyPushed
    case notFound
    case outOfBoundaries
}
