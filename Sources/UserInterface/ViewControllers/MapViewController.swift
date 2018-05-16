//
//  MapViewController.swift
//  AccuWeather
//
//  Created by Karshigabekov, Ilyas on 15/05/2018.
//  Copyright © 2018 Ilyas-Karshigabekov. All rights reserved.
//

import UIKit
import RxSwift
import MapKit
import RxCocoa

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var coordinates: CLLocationCoordinate2D?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinates = mapView.centerCoordinate
        
        mapView.delegate? = self
                }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectedLocation(_ sender: Any) {
        guard let coordinates = coordinates else {
            return
        }
        let core = try! Core.defaultNetworkCore()
        _ = Observable.just(LocationRequests(endPoint: "cities/geoposition/search", params: ["q":"\(coordinates.latitude),\(coordinates.longitude)"]))
            .flatMap {
            (request) -> Observable<SingleCityResponse> in
            return core.send(apiRequest: request)
            }
            .map{ $0.city
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                (city) in
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        coordinates = mapView.centerCoordinate
    }
}
