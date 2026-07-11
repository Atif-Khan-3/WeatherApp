//
//  HomeViewController.swift
//  SecondWeather
//
//  Created by Atif Khan  on 02/07/2026.
//

import UIKit

class HomeViewController: UIViewController {
    private var forecastCollectionView: UICollectionView!
    var tempurature:[String] = []
    var weatherViews : [Weather] = [.clear,.sunny,.partialCloudy,.cloudy,.raining,.storm,.raining]
    private lazy var viewModel = WeatherViewModel(repository: WeatherRepo(network: NetworkManager())
    )
    var weather3DModelCurrent = Weather3DView()


    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.reloadUI = { [weak self] in
            guard let self, let temp = self.viewModel.weather?.current.tempC else { return }
            let tempString = String(Int(temp))
            self.tempurature = tempString.map { String($0) }
            print("Got temp:", temp,tempurature)
            viewModel.prepareWeatherData()
            print("\(viewModel.weatherDays)")
            setupUIHorizontalScroll()
            setupWeatherView(weatherforcast: viewModel.weatherDays[0], weathertype: .clear)
        }

        viewModel.fetchWeather(city: "Islamabad")
        
    }
    func setupUIHorizontalScroll(){
        // view.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 85)
        layout.minimumLineSpacing = 10
        
        layout.sectionInset = UIEdgeInsets(top: 10, left:10, bottom: 15, right: 10)
        forecastCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        forecastCollectionView.translatesAutoresizingMaskIntoConstraints = false
        forecastCollectionView.backgroundColor = .clear
        forecastCollectionView.dataSource = self
        forecastCollectionView.delegate = self
        forecastCollectionView.register(ForecastViewCell.self, forCellWithReuseIdentifier: ForecastViewCell.identifier)
       
       
        forecastCollectionView.showsHorizontalScrollIndicator = false
        view.addSubview(forecastCollectionView)
        
        NSLayoutConstraint.activate([
           // forecastCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 700),
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: 10),
            forecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        forecastCollectionView.layer.zPosition = 1
       
    }
    func setupWeatherView(weatherforcast:WeatherDayModel, weathertype:Weather){
        view.bringSubviewToFront(forecastCollectionView)
        self.tempurature = weatherforcast.tempC.map { String($0) }
        weather3DModelCurrent.removeFromSuperview()
        weather3DModelCurrent = Weather3DView()
        
        weather3DModelCurrent.translatesAutoresizingMaskIntoConstraints = false
        weather3DModelCurrent.config(weatherforcast: weatherforcast, weather: weathertype)
        view.addSubview(weather3DModelCurrent)
        NSLayoutConstraint.activate([
            weather3DModelCurrent.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weather3DModelCurrent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weather3DModelCurrent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weather3DModelCurrent.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.bringSubviewToFront(forecastCollectionView)

    }
}


extension HomeViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastViewCell.identifier, for: indexPath) as! ForecastViewCell
        cell.config(with: viewModel.weatherDays[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.weatherDays.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let weather = viewModel.weatherDays[indexPath.row]
        setupWeatherView(weatherforcast: weather, weathertype:weatherViews[indexPath.row] )
    }
    
    
}




