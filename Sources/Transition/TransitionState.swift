//
//  TransitionState.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 21.12.2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import RxSwift

public class TransitionState {
    
    public static func empty() -> TransitionState {
        return TransionStateEmpty()
    }
    
    private let _completed = PublishSubject<Void>()
    public var completed: Completable {
        return _completed.ignoreElements()
    }
    
    internal func onCompleted() {
        _completed.onCompleted()
    }
    
    internal func onError(_ error: TransitionError) {
        _completed.onError(error)
    }
    
}

public class TransionStateEmpty: TransitionState {
    
    public override var completed: Completable {
        return .empty()
    }
    
    internal override func onCompleted() {}
    
    internal override func onError(_ error: TransitionError) {}
    
}
