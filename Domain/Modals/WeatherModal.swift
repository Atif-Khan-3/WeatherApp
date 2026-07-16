    //
    //  WeatherModal.swift
    //  SecondWeather
    //
    //  Created by Atif Khan  on 02/07/2026.
    //

    import Foundation
    struct Condition: Codable {
        let text: String
        let icon: String
        let code: Int
    }
    struct Location: Codable {

        let name: String
        let region: String
        let country: String
        let lat: Double
        let lon: Double
        let tzID: String
        let localtime: String

        enum CodingKeys: String, CodingKey {

            case name
            case region
            case country
            case lat
            case lon
            case localtime

            case tzID = "tz_id"

        }

    }
    struct WeatherResponse: Codable {

        let location: Location
        let current: Current
        let forecast: Forecast

    }
    struct Current: Codable {

        let tempC: Double
        let feelsLikeC: Double
        let humidity: Int
        let windKph: Double
        let pressure: Double
        let uv: Double
        let isDay: Int

        let condition: Condition

        enum CodingKeys: String, CodingKey {

            case tempC = "temp_c"
            case feelsLikeC = "feelslike_c"
            case humidity
            case windKph = "wind_kph"
            case pressure = "pressure_mb"
            case uv
            case isDay = "is_day"
            case condition

        }

    }
    struct Forecast: Codable {

        let forecastday: [ForecastDay]

    }
    struct ForecastDay: Codable {

        let date: String
        let day: Day
        let astro: Astro
        let hour: [Hour]

    }
    struct Day: Codable {

        let maxTemp: Double
        let minTemp: Double
        let avgTemp: Double

        let maxWind: Double
        let humidity: Int
        let UV: Double
        let chanceOfRain: Int
        

        let condition: Condition

        enum CodingKeys: String, CodingKey {

            case maxTemp = "maxtemp_c"
            case minTemp = "mintemp_c"
            case avgTemp = "avgtemp_c"
            case UV      = "uv"
            case maxWind = "maxwind_kph"

            case humidity = "avghumidity"

            case chanceOfRain = "daily_chance_of_rain"

            case condition

        }

    }
    struct Astro: Codable {

        let sunrise: String
        let sunset: String
        let moonrise: String
        let moonset: String
        let moon_phase:String
        let moon_illumination:Int
    }
    struct Hour: Codable {

        let time: String
        let tempC: Double
        let humidity: Int
        let chanceOfRain: Int

        let condition: Condition

        enum CodingKeys: String, CodingKey {

            case time

            case tempC = "temp_c"

            case humidity

            case chanceOfRain = "chance_of_rain"

            case condition

        }

    }

enum Weather: String, CaseIterable {
    case clear = "Clear"
    case sunny =  "Sunny"
    case partialCloudy = "Partialy Cloudy"
    case raining = "Raining"
    case cloudy = "Cloudy"
    case storm = "Storm"
    
}
