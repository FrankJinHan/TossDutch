//
//  Network.swift
//  TossDutch
//
//  Created by Frank Jin Han on 2021/07/25.
//

import Foundation

final class Network {
    static let shared = Network()
    
    private init() { }
    
    private let session = URLSession(configuration: .default)
    
    func request<T: NetworkType, R: Decodable>(type: T, result: R.Type, completionHandler: @escaping (R?, Error?) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: type.path) else {
            completionHandler(nil, DutchServiceError.urlParsingFailed)
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = type.method.rawValue
        
        return session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, DutchServiceError.requestNotAccepted)
                return
            }
            
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(R.self, from: data)
                    completionHandler(result, nil)
                } catch let error {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, DutchServiceError.unknownError)
            }
        })
    }
}

protocol NetworkType {
    var path: String { get }
    var method: HTTPMethodType { get }
}

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
}

enum TossDutch {
    case details
}

extension TossDutch: NetworkType {
    var path: String {
        switch self {
        case .details:
            return "https://ek7b8b8yq2.execute-api.us-east-2.amazonaws.com/default/toss_ios_homework_dutch_detail"
        }
    }
    
    var method: HTTPMethodType {
        switch self {
        case .details:
            return .get
        }
    }
}
