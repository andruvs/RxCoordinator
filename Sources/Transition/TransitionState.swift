//
//  TransitionState.swift
//  Articulation
//
//  Created by Andrey Golovchak on 21.12.2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation
import RxSwift

public class TransitionState {
    
    public static func empty() -> TransitionState {
        return TransionStateEmpty()
    }
    
    private let _completed = PublishSubject<Void>()
    public var completed: Observable<Void> {
        return _completed.asObservable()
    }
    
    private let _dismissed = PublishSubject<Void>()
    public var dismissed: Observable<Void> {
        return _dismissed.asObservable()
    }
    
    internal func complete() {
        _completed.onCompleted()
    }
    
    internal func dismiss() {
        complete()
        _dismissed.onCompleted()
    }
    
}

public class TransionStateEmpty: TransitionState {
    
    public override var completed: Observable<Void> {
        return .empty()
    }
    
    public override var dismissed: Observable<Void> {
        return .empty()
    }
    
    internal override func complete() {}
    
    internal override func dismiss() {}
    
}
