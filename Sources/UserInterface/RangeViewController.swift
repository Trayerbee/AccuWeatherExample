//
//  RangeViewController.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RangeViewController: UIViewController {

    @IBOutlet weak var oneDay: UIButton!
    @IBOutlet weak var fiveDays: UIButton!
    
    public var location: KeyedLocation?
    
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let location = location else {
            fatalError("No location set")
        }
        
        oneDay.rx
            .tap
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self]
               _ in
                let forecastTarget = Observable.just(OneDayForecast(endPoint: location.key, params: [:]))

                self.performSegue(withIdentifier: "forecast", sender: forecastTarget)
            }).disposed(by: bag)
        
        fiveDays.rx
            .tap
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self]
                _ in
                let forecastTarget = Observable.just(FiveDayForecast(endPoint: location.key, params: [:]))
                
                self.performSegue(withIdentifier: "forecast", sender: forecastTarget)
            }).disposed(by: bag)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cityVC = segue.destination as! CityForecastViewController
        cityVC.forecast = sender as? Observable<Target>
    }
}
