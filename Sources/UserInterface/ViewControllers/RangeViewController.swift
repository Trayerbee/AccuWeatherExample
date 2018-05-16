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
    @IBOutlet weak var cityNameLabel: UILabel!
    
    public var location: KeyedLocation?
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityNameLabel.text = "Weather for \(location?.localName ?? "unknown location")"
        
        oneDay.rx
            .tap
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self]
               _ in
                self.performSegue(withIdentifier: "forecast", sender: DaysNumber.oneDay)
            }).disposed(by: bag)
        
        fiveDays.rx
            .tap
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self]
                _ in
                self.performSegue(withIdentifier: "forecast", sender: DaysNumber.fiveDays)
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
        cityVC.location = location
        cityVC.numberOfDays = sender as? DaysNumber
    }
}
