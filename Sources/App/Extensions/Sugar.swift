//
//  Sugar.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

extension ObservableType where E == Void {
    
    /// Chain: sugar for beginning the declaration of an observable chain, allowing us
    ///   simply to specify the Scheduler that should be used when we subscribe.
    ///
    /// - Parameter scheduler: the Scheduler to start the observable chain from (from when we subscribe)
    /// - Returns: a Void Observable (i.e. passes nothing) on the given Scheduler.
    public static func chain(onScheduler scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Void> {
        return Observable<Void>.just(()).subscribeOn(scheduler)
    }
}

extension ObservableType {
    
    /// Discard the actual value being carried & just send an Event<Void> instead.
    public func eraseType() -> Observable<Void> {
        return self.map { _ in return () }
    }
    
    /// Flatmaps the Observable to match the expected type that it's being set to
    /// Any events received are mapped harmlessly to 'empty' i.e. complete.
    /// This is useful for terminating a chain of Presentations that we don't actually
    /// want the result of.
    public func toEmptyAsExpectedOuterType<R>() -> Observable<R> {
        return self.flatMap { _ -> Observable<R> in
            return Observable<R>.empty()
        }
    }
}
