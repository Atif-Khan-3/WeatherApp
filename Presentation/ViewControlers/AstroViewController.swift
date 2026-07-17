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
    
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let windRow = WeatherInfoRowView()
    private let humidityRow = WeatherInfoRowView()
    private let pressureRow = WeatherInfoRowView()
    private let uvRow = WeatherInfoRowView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.reloadUI = { [weak self] in
            guard let self, let temp = self.viewModel.weather?.current.tempC else { return }
            let tempString = String(Int(temp))
            
            viewModel.prepareWeatherData()
            print("\(viewModel.weatherDays)")
            setupUIHorizontalScroll()
            weatherView.config(weatherforcast: viewModel.weatherDays[0], weather: .partialCloudy)
            setupInfoStack()
        }
        view.addSubview(weatherView)
                weatherView.translatesAutoresizingMaskIntoConstraints = false
               
       
        NSLayoutConstraint.activate([
            weatherView.topAnchor.constraint(equalTo: view.topAnchor),
            weatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
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
            forecastCollectionView.heightAnchor.constraint(equalToConstant: 100),
            forecastCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: 10),
            forecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
           

            
        ])
        forecastCollectionView.layer.zPosition = 1
       
    }
    func setupInfoStack() {
        windRow.configure(title: "wind", value: "10")
        humidityRow.configure(title: "humidity", value: "55%")
        pressureRow.configure(title: "pressure", value: "1013 hPa")
        uvRow.configure(title: "uv index", value: "3")

        [windRow, humidityRow, pressureRow, uvRow].forEach {
            infoStackView.addArrangedSubview($0)
        }

        view.addSubview(infoStackView)
        infoStackView.layer.zPosition = 1

        NSLayoutConstraint.activate([
            infoStackView.bottomAnchor.constraint(equalTo: forecastCollectionView.topAnchor, constant: -10),
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            infoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
            
        ])
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


