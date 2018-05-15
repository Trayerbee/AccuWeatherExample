//
//  CitySearchViewModelTests.swift
//  VHI-iOS
//
//  Copyright © 2017 Ribot. All rights reserved.
//
//  swiftlint:disable force_try file_length type_body_length force_unwrap

import Foundation
import Nimble
import OHHTTPStubs
import XCTest

import RxSwift
import RxCocoa
import Shared
import Model
import Transport

@testable import UserInterface
@testable import ViewModels

/// Actions normally originate from the UIViewController, but for testing
/// we create here a handle of actions which we can control manually.
private struct ActionSubjects {
    // let tappedButtonSink = PublishSubject<Void>()
    func actions() -> CitySearchViewController.Actions {
        return CitySearchViewController.Actions(
            // tappedButton: ControlEvent(events: tappedButtonSink)
        )
    }
}

extension CitySearchViewModel.Result: AutoMatchable {}

extension CitySearchViewModel {
    fileprivate static func makeViewModel() -> (CitySearchViewModel, ActionSubjects) {
        let subjects = ActionSubjects() // would normally come from the VC, but this is our testable handle
        let dependencies = Dependencies(
            session: VhiSessionState.fake(),
            viewActions: subjects.actions()
        )
        let datasources = Datasources()
        
        let viewModel = CitySearchViewModel(dependencies: dependencies, datasources: datasources)
        return (viewModel, subjects)
    }
}

class CitySearchViewModelTests: DisposableTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testStartingState() {
        let (viewModel, _) = CitySearchViewModel.makeViewModel()

        let resultsSent = viewModel.result.storeNext()
        expect(resultsSent.count).toEventually(equal(0))

        let title = viewModel.title.storeNext()
        expect(title.count).toEventually(beGreaterThan(0))
        expect(title.last).toEventuallyNot(beEmpty())
    }

    func testDeinitThrowsAbort() {
        var nillable: CitySearchViewModel? = CitySearchViewModel.makeViewModel().0

        let result = nillable!.result.storeAll()

        nillable = nil

        let expected: Event<CitySearchViewModel.Result> = .error(ViewModel.Error.aborted)
        expect(result.last).toEventually(equal(expected))
    }
}
