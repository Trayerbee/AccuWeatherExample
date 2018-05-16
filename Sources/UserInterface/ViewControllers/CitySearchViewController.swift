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
                (request) -> Observable<MultipleCityResponse> in
                return core.send(apiRequest: request)
            }
            .map{ $0.cities }
            .bind(to: tableView.rx.items(cellIdentifier: "cityCell")) { index, model, cell in
                cell.textLabel?.text = model.localName
                cell.detailTextLabel?.text = "\(model.country.localName) \(model.area.localName)"
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(City.self).subscribe(
            onNext: { (city) in
            self.performSegue(withIdentifier: "forecast", sender: city)
        })
            .disposed(by: bag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "forecast" {
            let rangeVC = segue.destination as! RangeViewController
            rangeVC.location = sender as! City
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
