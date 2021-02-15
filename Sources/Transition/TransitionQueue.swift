//
//  TransitionQueue.swift
//  RxCoordinator
//
//  Created by Andrey Golovchak on 15.02.2021.
//

import Foundation

internal class TransitionQueue {
    
    let queue = DispatchQueue(label: "andruvs.RxCoordinator.TransitionQueue", qos: .userInteractive)
    
    var tasks = [TransitionTask]()
    
    var isRunning = false
    
    func append(_ task: TransitionTask) {
        queue.async { [weak self] in
            self?.tasks.append(task)
        }
        checkQueue()
    }
    
    func checkQueue(reset: Bool = false) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if reset {
                self.isRunning = false
            }
            
            if self.isRunning || self.tasks.isEmpty {
                return
            }
            
            self.isRunning = true
            
            let task = self.tasks.removeFirst()
            
            task.execute { [weak self] in
                self?.checkQueue(reset: true)
            }
        }
    }
    
}
