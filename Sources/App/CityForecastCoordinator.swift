//
//  CityForecastCoordinator.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Freddy

class CityForecastCoordinator: CoordinatorType {
    enum Result: CoordinatorResultType {
    }
    
    static var identifier = "Maintenance"
    let presenter: UINavigationController
    
    private let bag = DisposeBag()
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func results() -> Observable<Result> {
        return Observable
            .chain(onScheduler: MainScheduler.instance)
            .flatMap { [unowned self] in
                // Present pre-login landing screen:
                return self.pushMaintenanceLockViewController(message: self.message)
            }
            .flatMap {
                (result) -> Observable<MaintenanceLockCoordinator.Result> in
                switch result {
                case .tappedAppStore:
                    guard let url = URL(string: "itms://itunes.apple.com/app/id1266282746") else {
                        return Observable.empty()
                    }
                    UIApplication.shared.openURL(url)
                }
                return Observable.empty()
        } //There is no way out of this one, no results.
    }
}
