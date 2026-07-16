//
//  NetworkService.swift
//  SecondWeather
//
//  Created by Atif Khan  on 02/07/2026.
//

import Foundation
protocol NetworkServiceProtocol {

    func request<T:Decodable>(
        endpoint: Endpoint,
        completion:@escaping(Result<T,Error>)->Void
    )

}
class NetworkManager: NetworkServiceProtocol {

    func request<T: Decodable>(
        endpoint: Endpoint,
        completion:@escaping(Result<T,Error>)->Void
    ) {

        guard let url = URL(string: endpoint.url) else {
            completion(.failure(URLError(.badURL)))
            return

        }

        URLSession.shared.dataTask(with: url) {

            data,response,error in

            if let error {

                completion(.failure(error))
                return

            }

            guard let data else {

                return

            }

            do{

                let result = try JSONDecoder().decode(T.self, from: data)

                completion(.success(result))

            }

            catch{
                print("Decoding error:", error)
                completion(.failure(error))

            }

        }.resume()

    }

}
