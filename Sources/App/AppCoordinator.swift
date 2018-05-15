//
//  AppCoordinator.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import Freddy
import RxSwiftExt

class AppCoordinator: CoordinatorType {
    static var identifier = "Application"
    static var defaultTransitionDuration = 0.35 // https://stackoverflow.com/a/7609370/349364
    
    internal let presenter: CoordinatedBaseViewController
    private let window: UIWindow
    
    
    private let appDidEnterForeground: Observable<Date>
    private let appDidEnterBackground: Observable<Date>
    
    enum Result: CoordinatorResultType {
        // never completes, so no cases here.
    }
    
    private let bag = DisposeBag()
    private var childCoordinatorBag = DisposeBag() // for retaining child coordinator subscriptions only.
    
    
    /// Creates the main app coordinator
    /// - Parameters:
    ///   - window: The app window
    ///   - urlInput: An observable that monitors any URLs that have been received by the app
    init(window: UIWindow) {
        self.window = window
        
        // Presenter on AppCoordinator is a "base" view controller on which everything is added as a child.
        self.presenter = CoordinatedBaseViewController()
        
    }
    
    func results() -> Observable<Result> {
        
        // The App Coordinator doesn't really send results as it's the root.
        // Just setup the UI stack as soon as someone subscribes to us.
        
        return Observable<Result>
            .empty() // never complete
            .do(onSubscribe: { [unowned self] in
                
                self.window.rootViewController = self.presenter
                self.window.makeKeyAndVisible()
                self.startLandingCoordinator()
            })
    }
    
    private func startLandingCoordinator() {
        
        LandingCoordinator
            .startAsChild {
                return LandingCoordinator(
                    presenter: self.presenter.vendNavigationPresenter(for: LandingCoordinator.identifier)
                )
            }
            .observeOn(MainScheduler.instance)
            .presentErrorAsAlert(presenter: presenter)
            .subscribe(
                onNext: { [unowned self]
                    (result: LandingCoordinator.Result) in
                    
                    switch result {
                    case .loggedInSuccessfully(let sessionCredentials):
                        self.session.currentValue = sessionCredentials
                    }
                },
                onError: { [unowned self]
                    (error: Error) in
                    self.presenter.removeCoordinatedChildViewController(identifier: LandingCoordinator.identifier)
                    self.proceed()
                },
                onCompleted: { [unowned self] in
                    self.presenter.removeCoordinatedChildViewController(identifier: LandingCoordinator.identifier)
                    self.proceed()}
            ).disposed(by: childCoordinatorBag)
    }
}
