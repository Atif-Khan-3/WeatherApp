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

            return "https://api.weatherapi.com/v1/forecast.json?key=f8d31930a4b9490990485637260107&q=\(city)&days=7&aqi=no&alerts=no"

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
        network.request(endpoint: .forecast(city: city),
        completion: completion)
    }
}
