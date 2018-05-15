//
//  CitySearch.swift
//  VHI-iOS
//
//  Copyright © 2017 Ribot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension CoordinatorType where Presenter == UINavigationController {

    func pushCitySearch() -> Observable<CitySearchViewModel.Result> {
        let result = PublishSubject<CitySearchViewModel.Result>()
        let viewController = CitySearchViewModel.vendViewController(result: result)

        // Push the container on the current presenter:
        presenter.pushViewController(viewController, animated: true)

        return result
            .share(replay: 1)
            .observeOn(MainScheduler.instance)
    }

// OR ALTERNATIVELY:
//    func setRootAsCitySearch(session: VhiSessionState) -> Observable<CitySearchViewModel.Result> {
//        let result = PublishSubject<CitySearchViewModel.Result>()
//        let viewController = CitySearchViewModel.vendViewController(session: session, result: result)
//
//        // Set the container on the current presenter
//        presenter.viewControllers = [viewController]
//
//        return result
//            .share(replay: 1)
//            .observeOn(MainScheduler.instance)
//    }
}

extension CitySearchViewModel {

    fileprivate static func vendViewController(result: PublishSubject<CitySearchViewModel.Result>) -> CitySearchViewController {

        return CitySearchViewController.create(viewModelFactory: {
            (viewController: CitySearchViewController) -> CitySearchViewModelType in

            let datasources = Datasources()
            let dependencies = Dependencies(session: session, viewActions: viewController.actions)
            let viewModel = CitySearchViewModel(dependencies: dependencies, datasources: datasources)
            viewModel.result.bind(to: result).disposed(by: viewController.rx.disposeBag)
            return viewModel
        })
    }
}
