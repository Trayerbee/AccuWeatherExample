//
//  CityForecastViewController.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class CityForecastViewController: UIViewController {

    public var city: CityResponse.City?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dayConditionLabel: UILabel!
    @IBOutlet weak var nightConditionLabel: UILabel!
    @IBOutlet weak var generalCondition: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let core = try! Core.defaultNetworkCore()

        
        let bag = DisposeBag()
        
        guard let city = city else {
            fatalError("No city set")
        }
        
        let forecastRequest = OneDayForecast(endPoint:city.key, params: [:])
        
        title = city.localName
        
        _ = Observable.just(forecastRequest)
            .flatMap {
                (request) -> Observable<ForecastResponse> in
                return core.send(apiRequest: request)
            }
            .asObservable()
            .subscribe(onNext: {
                (response) in
                guard let forecast = response.forecasts.first else {
                    return
                }
                self.dateLabel.text = "Forecast for \(forecast.date.description)"
                self.temperatureLabel.text = "Temperature range from \(forecast.temperature.minimum) to \(forecast.temperature.maximum)"
                self.dayConditionLabel.text = "Day condition \(forecast.dayCondition)"
                self.nightConditionLabel.text = "Night condition \(forecast.nightCondition)"
                self.generalCondition.text = response.headline

            }, onError: {
                print($0)
            })
            .disposed(by: bag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
