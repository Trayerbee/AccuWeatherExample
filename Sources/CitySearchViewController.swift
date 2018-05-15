//
//  CitySearchViewController.swift
//  VHI-iOS
//
//  Copyright © 2017 Ribot. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol CitySearchViewModelType {
    var title: Driver<String> {get}
}

public class CitySearchViewController: BaseBoundViewController<CitySearchViewModelType> {
    public struct Actions {
    }

    override func bindTo(viewModel: CitySearchViewModelType) {
        viewModel.title.drive(rx.title).disposed(by: rx.disposeBag)
    }
}

public extension CitySearchViewController {
    public var actions: Actions {
        return Actions()
    }
}

// Default usage of this screen:
public extension CitySearchViewController {
    public static func create(viewModelFactory: @escaping  (CitySearchViewController) -> CitySearchViewModelType) -> CitySearchViewController {

        guard let viewController = create(storyboard: UIStoryboard(name: "CitySearch", bundle: Bundle.main), viewModelFactory: downcast(closure: viewModelFactory)) as? CitySearchViewController else {
            fatalError("Error: ViewController cannot be force-casted to CitySearchViewController, aborting.")
        }
        return viewController
    }
}
