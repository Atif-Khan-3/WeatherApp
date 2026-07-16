//
//  AstroViewController.swift
//  SecondWeather
//
//  Created by Atif Khan  on 15/07/2026.
//

import UIKit

class AstroViewController: UIViewController {
    private let weatherView = WeatherOrbitView()
    private lazy var viewModel = WeatherViewModel(repository: WeatherRepo(network: NetworkManager()))
    private var forecastCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reloadUI = { [weak self] in
            guard let self, let temp = self.viewModel.weather?.current.tempC else { return }
            let tempString = String(Int(temp))
            
            viewModel.prepareWeatherData()
            print("\(viewModel.weatherDays)")
            setupUIHorizontalScroll()
            
        }
        view.addSubview(weatherView)
                weatherView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    weatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    weatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    weatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    weatherView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        let today = WeatherDayModel(
                    day: "Tuesday",
                    tempC: "24",
                    tempCMax: "27",
                    tempCMin: "19",
                    text: "Partly Cloudy",
                    icon: "116",
                    moonPhases: "Waxing Gibbous",
                    moonRise: "18:20",
                    moonSet: "05:10",
                    moonIlumination: 90,
                    sunRise: "05:45",
                    sunSet: "19:32",
                    sunUVIndex: "6"
                )
        weatherView.config(
                  weatherforcast: today,
                  weather: .partialCloudy,
                  windDirectionDegrees: 0
              )
        setupUIHorizontalScroll()
        
        viewModel.fetchWeather(city: "Islamabad")
        
    }
    
    func setupUIHorizontalScroll(){
        
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
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: 10),
            forecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        forecastCollectionView.layer.zPosition = 1
       
    }
  

}

extension AstroViewController:UICollectionViewDataSource,UICollectionViewDelegate{
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
        weatherView.config(
                  weatherforcast: weather,
                  weather: .partialCloudy,
                  windDirectionDegrees: 0
              )
    }
    
    
}


