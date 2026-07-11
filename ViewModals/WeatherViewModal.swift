//
//  WeatherViewModal.swift
//  SecondWeather
//
//  Created by Atif Khan  on 02/07/2026.
//

import Foundation
class WeatherViewModel {
    
    private let repository: ForecastProtocol
    var weatherDays: [WeatherDayModel] = []
    init(repository: ForecastProtocol) {
        
        self.repository = repository
        
    }
    
    var weather: WeatherResponse?
    
    var reloadUI:(()->Void)?
    
    func fetchWeather(city:String){
        
        repository.getWeather(city: city) { [weak self] result in
            
            switch result{
                
            case .success(let response):
                
                self?.weather = response
                
                DispatchQueue.main.async{
                    
                    self?.reloadUI?()
                    
                }
                
            case .failure(let error):
                
                print(error)
                
            }
            
        }
        
    }
    func prepareWeatherData() {
        
        weatherDays.removeAll()
        
        if let weather = weather {
            let current = WeatherDayModel(
                day: "Today",
                tempC: "\(Int(weather.current.tempC))°",
                text: weather.current.condition.text,
                icon: "https:\(weather.current.condition.icon)"
            )
            
         //   weatherDays.append(current)
            for forecastDay in weather.forecast.forecastday.prefix(7) {
                
                let model = WeatherDayModel(
                    day: forecastDay.date,
                    tempC: "\(Int(forecastDay.day.avgTemp))°",
                    text: forecastDay.day.condition.text,
                    icon: "https:\(forecastDay.day.condition.icon)"
                )
                
                weatherDays.append(model)
            }
            
        }
    }
}


struct WeatherDayModel {
    let day: String
    let tempC: String
    let text: String
    let icon: String
}
