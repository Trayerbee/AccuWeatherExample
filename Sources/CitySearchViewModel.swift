//
//  CitySearchViewModel.swift
//  VHI-iOS
//
//  Copyright © 2017 Ribot. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class CitySearchViewModel: CitySearchViewModelType {

    public struct Dependencies: AutoInitable {
        public let session: VhiSessionState
        public let viewActions: CitySearchViewController.Actions
    }

    public struct Datasources: AutoInitable {}

    public enum Result: AutoEquatable {
    }

    public let result: Observable<Result>

    public let title = Driver<String>.just("~Title Here~")

    public required init(dependencies: Dependencies, datasources: Datasources) {
        let internalResult = Observable<Result>.never() // TODO: Replace or remove me

        self.result = Observable.from([internalResult, willDeinit]).merge()
    }

    fileprivate let willDeinit = PublishSubject<Result>()
    deinit {
        willDeinit.onError(ViewModel.Error.aborted)
    }
}
