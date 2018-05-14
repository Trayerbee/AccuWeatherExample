//
//  CitySearchViewController.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 14/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CitySearchViewController: UIViewController {

    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search city"

        let core = try! Core.defaultNetworkCore()
                
        searchText.rx.text.asObservable()
            .filter {
                guard let text = $0 else
                { return false }
                return text.count > 3
            }
            .map{ ($0 ?? "").lowercased() }
            .distinctUntilChanged()
            .throttle(1, scheduler: MainScheduler.asyncInstance)
            .map{ LocationRequests(endPoint: "cities/autocomplete", params: ["q":$0])}
            .flatMap {
                (request) -> Observable<CityResponse> in
                return core.send(apiRequest: request)
            }
            .map{ $0.cities }
            .bind(to: tableView.rx.items(cellIdentifier: "cityCell")) { index, model, cell in
                cell.textLabel?.text = model.localName
                cell.detailTextLabel?.text = "\(model.country.localName) \(model.area.localName)"
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(CityResponse.City.self).subscribe(
            onNext: { (city) in
            self.performSegue(withIdentifier: "city", sender: city)
        })
            .disposed(by: bag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let forecastVC = segue.destination as! CityForecastViewController
        forecastVC.city = sender as? CityResponse.City
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
