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

    public var forecast: Observable<Target>?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dayConditionLabel: UILabel!
    @IBOutlet weak var nightConditionLabel: UILabel!
    @IBOutlet weak var generalCondition: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let bag = DisposeBag()

    let core = try! Core.defaultNetworkCore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let forecast = forecast else {
            fatalError("No city set")
        }
        
        title = "Forecast"
        
        
        forecast
            .flatMap{ [unowned self]
                (request) -> Observable<ForecastResponse> in
                return self.core.send(apiRequest: request)

            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                (response) in
                guard let forecast = response.forecasts.first else {
                    return
                }
                
                self.activityIndicator.stopAnimating()
                
                self.dateLabel.text = "Forecast for \(forecast.readableDate)"
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
