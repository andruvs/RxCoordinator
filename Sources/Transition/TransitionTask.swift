//
//  TransitionTask.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 22.12.2020.
//  Copyright © 2020 Andrew Golovchak. All rights reserved.
//

import Foundation
import RxSwift

typealias TransitionClosure = ((TransitionState) -> Void)

internal class TransitionTask {
    
    private let disposeBag = DisposeBag()
    
    let state = TransitionState()
    let closure: TransitionClosure?
    
    init(_ closure: TransitionClosure?) {
        self.closure = closure
    }
    
    func execute(_ completion: (() -> Void)?) {
        
        guard let closure = closure else {
            completion?()
            return
        }
        
        state.completed
            .subscribe { _ in
                completion?()
            }
            .disposed(by: disposeBag)
        
        DispatchQueue.main.async {
            closure(self.state)
        }
    }
    
}
