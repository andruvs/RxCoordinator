//
//  TransitionState.swift
//  Articulation
//
//  Created by Andrey Golovchak on 21.12.2020.
//  Copyright © 2020 SCID. All rights reserved.
//

import Foundation
import RxSwift

class TransitionState {
    
    static func empty() -> TransitionState {
        return TransionStateEmpty()
    }
    
    private let _completed = PublishSubject<Void>()
    var completed: Observable<Void> {
        return _completed.asObservable()
    }
    
    private let _dismissed = PublishSubject<Void>()
    var dismissed: Observable<Void> {
        return _dismissed.asObservable()
    }
    
    func complete() {
        _completed.onCompleted()
    }
    
    func dismiss() {
        complete()
        _dismissed.onCompleted()
    }
    
}

class TransionStateEmpty: TransitionState {
    
    override var completed: Observable<Void> {
        return .empty()
    }
    
    override var dismissed: Observable<Void> {
        return .empty()
    }
    
    override func complete() {}
    
    override func dismiss() {}
    
}
