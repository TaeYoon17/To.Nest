//
//  TaskCounter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import UIKit
import Combine

actor TaskCounter{
    @Published private(set) var count = 0
    private(set) var maxCount: Int
    private var completed = PassthroughSubject<Bool,Never>()
    private var subscription = Set<AnyCancellable>()
    init(max:Int = 0) {
        self.maxCount = max
    }
    private func changeMax(_ max:Int){
        self.maxCount = max
    }
    private func increment(){
        count += 1
        if maxCount == count{
            count = 0
            completed.send(true)
        }
    }
    private func reset(){ count = 0 }
    private func failed(){ completed.send(false) }
    func sink(receiveValue:@escaping (Bool)->Void)-> Subscribers.Sink<Bool,Never>{
        let sinker = Subscribers.Sink<Bool,Never>.init { _ in } receiveValue: { val in
            receiveValue(val)
        }
        completed.subscribe(sinker)
        return sinker
    }
}
extension TaskCounter{
    func run<T>(_ results: [T],action:@escaping ((T) async throws ->Void)) async throws{
        subscription.removeAll()
        self.changeMax(results.count)
        self.reset()
        try await withThrowingTaskGroup(of: Void.self) { group in
            for result in results{
                group.addTask {
                    do{
                        try await action(result)
                        await self.increment()
                    }catch{
                        await self.failed()
                    }
                }
            }
            self.sink(receiveValue: {[group] val in
                if !val{ group.cancelAll() }
            }).store(in: &subscription)
            try await group.waitForAll()
        }
    }
    func run<T,S>(_ results: [T],action:@escaping ((T) async throws ->S)) async throws -> [S]{
        subscription.removeAll()
        self.changeMax(results.count)
        self.reset()
        return try await withThrowingTaskGroup(of: S.self) { group in
            for result in results{
                group.addTask {
                    do{
                        let res = try await action(result)
                        await self.increment()
                        return res
                    }catch{
                        await self.failed()
                        throw error
                    }
                }
            }
            self.sink(receiveValue: {[group] val in
                if !val{
                    group.cancelAll()
                }
            }).store(in: &subscription)
            
            var arr:[S] = []
            for try await v in group{ arr.append(v) }
            try await group.waitForAll()
            return arr
        }
    }
}
extension TaskCounter{
    enum CounterError: Error{
        case actionError
    }
}
