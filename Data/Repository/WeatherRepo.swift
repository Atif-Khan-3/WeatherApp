//
//  WeatherRepo.swift
//  SecondWeather
//
//  Created by Atif Khan  on 02/07/2026.
//

import Foundation
enum Endpoint {

    case forecast(city:String)

    var url:String {

        switch self {

        case .forecast(let city):

            return "https://api.weatherapi.com/v1/forecast.json?key=ec6b245a58274ee99ac74943261407&q=33.64451953183405,73.02232599031989&days=7&aqi=no&alerts=no"

        }

    }

}
protocol ForecastProtocol{
  
    func getWeather(
        city:String,
        completion: @escaping(Result<WeatherResponse,Error>) -> Void
    )
}
class WeatherRepo:ForecastProtocol{
    private let network:NetworkServiceProtocol
    init(network:NetworkServiceProtocol){
        self.network = network
    }
    func getWeather(city: String, completion: @escaping (Result<WeatherResponse, any Error>) -> Void) {
        
        var coordinates = "\(LocationManager.shared.latitude),\(LocationManager.shared.longitude)"
        
        network.request(endpoint: .forecast(city: coordinates),
        completion: completion)
    }
}
