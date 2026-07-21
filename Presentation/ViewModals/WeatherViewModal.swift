//
//  WeatherViewModal.swift
//  SecondWeather
//
//  Created by Atif Khan  on 02/07/2026.
//

import Foundation
import Combine
class WeatherViewModel: ObservableObject {
    
    @Published var front: Int = 0
    @Published var selectedDay: Int = 0
    static let shared = LocationManager()
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
         
            for forecastDay in weather.forecast.forecastday.prefix(7) {
                
                let model = WeatherDayModel(
                    day: forecastDay.date,
                    tempC: "\(Int(forecastDay.day.avgTemp))°",
                    tempCMax: "\(Int(forecastDay.day.maxTemp))°",
                    tempCMin: "\(Int(forecastDay.day.minTemp))°",
                    text: forecastDay.day.condition.text,
                    icon: "https:\(forecastDay.day.condition.icon)",
                    moonPhases: forecastDay.astro.moon_phase,
                    moonRise: forecastDay.astro.moonrise,
                    moonSet: forecastDay.astro.moonset,
                    moonIlumination: forecastDay.astro.moon_illumination,
                    sunRise: forecastDay.astro.sunrise,
                    sunSet: forecastDay.astro.sunset,
                    sunUVIndex: "\(forecastDay.day.UV)",
                    winddegree: forecastDay.hour[0].winddegree,
                    windSpeed: forecastDay.hour[0].windSpeed,
                    windDirection: forecastDay.hour[0].windDirection,
                    airPressure: forecastDay.hour[0].airPressure
                    
                )
                
                weatherDays.append(model)
            }
            
        }
    }
}


struct WeatherDayModel {
    let day: String
    let tempC: String
    let tempCMax: String
    let tempCMin: String
    
    let text: String
    let icon: String
    let moonPhases:String
    let moonRise:String
    let moonSet:String
    let moonIlumination:Int
    
    let sunRise:String
    let sunSet:String
    let sunUVIndex:String
    
    
    let winddegree: Int
    let windSpeed: Double
    let windDirection: String
    let airPressure: Double
    
}
