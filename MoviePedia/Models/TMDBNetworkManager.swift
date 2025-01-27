//
//  TMDBNetworkManager.swift
//  MoviePedia
//
//  Created by 임윤휘 on 1/27/25.
//

import Foundation
import Alamofire

class TMDBNetworkManager {
    static let shared = TMDBNetworkManager()
    
    private init(){}
    
    func request<T: Decodable>(api: TMDBNetworkAPI, successHandler: @escaping ((T) -> Void), failureHandler: @escaping ((Error) -> Void)) {
        guard let url = api.endPoint else {
            print("Failed to create url")
            return
        }
        
        AF.request(url, method: api.method, parameters: api.parameters, encoding: URLEncoding(destination: .queryString), headers: api.headers)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    successHandler(value)
                case .failure(let error):
                    print("ERRORL:", error)
                    failureHandler(error)
                }
            }
    }
}
